# frozen_string_literal: true

require "sidekiq"
require "pony"

require_relative "logger_manager"

module MyApplicationKostyk
  # Клас ArchiveSenderWorker - Sidekiq worker для відправки архівів по email
  # Виконує відправку у фоновому режимі
  class ArchiveSenderWorker
    include Sidekiq::Job

    # Налаштування Sidekiq
    sidekiq_options queue: "default", retry: 3

    # Виконує відправку архіву на email
    # @param archive_path [String] шлях до архіву
    # @param recipient_email [String] email отримувача
    def perform(archive_path, recipient_email)
      LoggerManager.log_info("[ArchiveSenderWorker] Відправка архіву на #{recipient_email}")

      unless File.exist?(archive_path)
        LoggerManager.log_error("[ArchiveSenderWorker] Файл архіву не знайдено: #{archive_path}")
        return
      end

      send_email(archive_path, recipient_email)
      LoggerManager.log_info("[ArchiveSenderWorker] Архів успішно відправлено на #{recipient_email}")
    rescue StandardError => e
      LoggerManager.log_error("[ArchiveSenderWorker] Помилка відправки", e)
      raise # Повторна спроба через Sidekiq
    end

    private

    # Відправляє email з архівом
    # @param archive_path [String] шлях до архіву
    # @param recipient_email [String] email отримувача
    def send_email(archive_path, recipient_email)
      Pony.mail(
        to: recipient_email,
        from: smtp_config[:from] || "noreply@booksparser.local",
        subject: "Books Parser - Архів даних #{Time.now.strftime('%Y-%m-%d %H:%M')}",
        body: email_body(archive_path),
        attachments: { File.basename(archive_path) => File.read(archive_path, mode: "rb") },
        via: :smtp,
        via_options: smtp_options
      )
    end

    # Формує тіло листа
    # @param archive_path [String] шлях до архіву
    # @return [String] тіло листа
    def email_body(archive_path)
      file_size = (File.size(archive_path) / 1024.0).round(2)
      <<~BODY
        Доброго дня!

        Архів з результатами парсингу сайту Books to Scrape готовий.

        Деталі:
        - Файл: #{File.basename(archive_path)}
        - Розмір: #{file_size} KB
        - Дата створення: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}

        З повагою,
        Ruby Web Parser
      BODY
    end

    # Налаштування SMTP
    # @return [Hash] налаштування SMTP
    def smtp_options
      {
        address: smtp_config[:address] || "smtp.gmail.com",
        port: smtp_config[:port] || "587",
        user_name: smtp_config[:user_name] || ENV["SMTP_USER"],
        password: smtp_config[:password] || ENV["SMTP_PASSWORD"],
        authentication: :plain,
        enable_starttls_auto: true,
        domain: smtp_config[:domain] || "localhost"
      }
    end

    # Отримує конфігурацію SMTP з ENV або дефолтні значення
    # @return [Hash] конфігурація SMTP
    def smtp_config
      {
        address: ENV["SMTP_ADDRESS"],
        port: ENV["SMTP_PORT"],
        user_name: ENV["SMTP_USER"],
        password: ENV["SMTP_PASSWORD"],
        from: ENV["SMTP_FROM"],
        domain: ENV["SMTP_DOMAIN"]
      }
    end
  end
end

