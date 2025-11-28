# frozen_string_literal: true

require "zip"
require "fileutils"

require_relative "my_application_kostyk"
require_relative "app_config_loader"
require_relative "logger_manager"
require_relative "configurator"
require_relative "simple_website_parser"
require_relative "database_connector"
require_relative "item_collection"

module MyApplicationKostyk
  # Клас Engine - головний клас для управління виконанням програми
  # Відповідає за завантаження конфігурації, ініціалізацію логування,
  # виконання парсингу та збереження даних у різних форматах
  class Engine
    attr_reader :config, :config_loader, :configurator, :parser, :db_connector, :item_collection

    # Конструктор класу
    def initialize
      @config = {}
      @config_loader = nil
      @configurator = nil
      @parser = nil
      @db_connector = nil
      @item_collection = nil
      @output_files = []
    end

    # Завантажує конфігурацію з YAML-файлів
    # @return [Hash] завантажена конфігурація
    def load_config
      LoggerManager.log_info("[Engine] Завантаження конфігурації...")

      @config_loader = AppConfigLoader.new
      config_path = File.join(MyApplicationKostyk.config_path, "default_config.yaml")
      @config_loader.config(config_path, MyApplicationKostyk.config_path)
      @config = @config_loader.config_data

      LoggerManager.log_info("[Engine] Конфігурацію завантажено успішно")
      puts "✓ Конфігурацію завантажено"

      @config
    rescue StandardError => e
      LoggerManager.log_error("[Engine] Помилка завантаження конфігурації", e)
      raise
    end

    # Головний метод для запуску програми
    # @param config_params [Hash] параметри конфігурації для виконання
    def run(config_params = {})
      puts "\n" + "=" * 60
      puts "ЗАПУСК ENGINE - Ruby Web Parser"
      puts "=" * 60

      begin
        # 1. Завантаження конфігурації
        load_config

        # 2. Ініціалізація логування
        initialize_logging

        # 3. Ініціалізація конфігуратора з параметрами
        @configurator = Configurator.new
        @configurator.configure(config_params)

        LoggerManager.log_info("[Engine] Параметри виконання:")
        config_params.each { |k, v| LoggerManager.log_info("  #{k}: #{v}") }

        # 4. Підключення до бази даних (якщо потрібно)
        connect_to_database if should_use_database?

        # 5. Виконання методів на основі конфігурації
        run_methods(config_params)

        # 6. Архівація файлів (якщо є що архівувати)
        archive_output_files if @output_files.any?

        # 7. Відключення від бази даних
        disconnect_from_database

        puts "\n" + "=" * 60
        puts "ENGINE ЗАВЕРШИВ РОБОТУ УСПІШНО"
        puts "=" * 60

        LoggerManager.log_info("[Engine] Робота завершена успішно")
      rescue StandardError => e
        LoggerManager.log_error("[Engine] Критична помилка виконання", e)
        puts "\n❌ Помилка: #{e.message}"
        disconnect_from_database
        raise
      end
    end

    # Виконує методи на основі параметрів конфігурації
    # @param config_params [Hash] параметри конфігурації
    def run_methods(config_params)
      LoggerManager.log_info("[Engine] Виконання методів на основі конфігурації...")

      # Список методів для виконання
      methods_to_run = %i[
        run_website_parser
        run_save_to_csv
        run_save_to_json
        run_save_to_yaml
        run_save_to_sqlite
        run_save_to_mongodb
      ]

      methods_to_run.each do |method_name|
        # Перевіряємо чи метод увімкнено в конфігурації
        if @configurator.enabled?(method_name)
          begin
            LoggerManager.log_info("[Engine] Виконання методу: #{method_name}")
            send(method_name)
          rescue StandardError => e
            LoggerManager.log_error("[Engine] Помилка виконання методу #{method_name}", e)
            puts "  ❌ Помилка #{method_name}: #{e.message}"
          end
        else
          LoggerManager.log_info("[Engine] Метод #{method_name} вимкнено")
        end
      end
    end

    # ============================================
    # Методи для виконання
    # ============================================

    # Запускає парсинг веб-сайту
    def run_website_parser
      puts "\n📚 Запуск парсингу сайту Books to Scrape..."
      LoggerManager.log_info("[Engine] Запуск парсингу сайту")

      @parser = SimpleWebsiteParser.new(@config)
      max_pages = @configurator.get(:parser_max_pages) || 0
      use_threads = @configurator.get(:use_threads) != 0

      @item_collection = @parser.start_parse(max_pages: max_pages, use_threads: use_threads)

      puts "  ✓ Зібрано книг: #{@item_collection.size}"
      puts "  ✓ Загальна вартість: £#{@item_collection.total_price.round(2)}"

      LoggerManager.log_info("[Engine] Парсинг завершено. Зібрано #{@item_collection.size} книг")
    rescue StandardError => e
      LoggerManager.log_error("[Engine] Помилка парсингу", e)
      raise
    end

    # Зберігає дані у форматі CSV
    def run_save_to_csv
      ensure_collection_exists

      puts "\n💾 Збереження у CSV..."
      output_file = File.join(MyApplicationKostyk.output_path, "books_export.csv")
      @item_collection.save_to_csv(output_file)
      @output_files << output_file

      puts "  ✓ Збережено: #{output_file}"
      LoggerManager.log_info("[Engine] Збережено CSV: #{output_file}")
    rescue StandardError => e
      LoggerManager.log_error("[Engine] Помилка збереження CSV", e)
      raise
    end

    # Зберігає дані у форматі JSON
    def run_save_to_json
      ensure_collection_exists

      puts "\n💾 Збереження у JSON..."
      output_file = File.join(MyApplicationKostyk.output_path, "books_export.json")
      @item_collection.save_to_json(output_file)
      @output_files << output_file

      puts "  ✓ Збережено: #{output_file}"
      LoggerManager.log_info("[Engine] Збережено JSON: #{output_file}")
    rescue StandardError => e
      LoggerManager.log_error("[Engine] Помилка збереження JSON", e)
      raise
    end

    # Зберігає дані у форматі YAML
    def run_save_to_yaml
      ensure_collection_exists

      puts "\n💾 Збереження у YAML..."
      output_dir = File.join(MyApplicationKostyk.output_path, "books_yaml")
      @item_collection.save_to_yml(output_dir)
      @output_files << output_dir

      puts "  ✓ Збережено: #{output_dir}"
      LoggerManager.log_info("[Engine] Збережено YAML: #{output_dir}")
    rescue StandardError => e
      LoggerManager.log_error("[Engine] Помилка збереження YAML", e)
      raise
    end

    # Зберігає дані у базу даних SQLite
    def run_save_to_sqlite
      ensure_collection_exists
      ensure_db_connected("sqlite")

      puts "\n💾 Збереження у SQLite..."
      @db_connector.create_tables
      saved_count = @db_connector.save_items(@item_collection)

      puts "  ✓ Збережено #{saved_count} книг у SQLite"
      LoggerManager.log_info("[Engine] Збережено #{saved_count} книг у SQLite")
    rescue StandardError => e
      LoggerManager.log_error("[Engine] Помилка збереження у SQLite", e)
      raise
    end

    # Зберігає дані у базу даних MongoDB
    def run_save_to_mongodb
      ensure_collection_exists

      puts "\n💾 Збереження у MongoDB..."

      # Створюємо окремий конектор для MongoDB
      mongodb_config = @config.dup
      mongodb_config["database"] = mongodb_config["database"].dup if mongodb_config["database"]
      mongodb_config["database"]["type"] = "mongodb"

      mongo_connector = DatabaseConnector.new(mongodb_config)
      mongo_connector.connect_to_database
      saved_count = mongo_connector.save_items(@item_collection)
      mongo_connector.close_connection

      puts "  ✓ Збережено #{saved_count} книг у MongoDB"
      LoggerManager.log_info("[Engine] Збережено #{saved_count} книг у MongoDB")
    rescue StandardError => e
      LoggerManager.log_error("[Engine] Помилка збереження у MongoDB", e)
      puts "  ⚠ MongoDB недоступний: #{e.message}"
    end

    # ============================================
    # Архівація
    # ============================================

    # Архівує створені файли у ZIP
    def archive_output_files
      puts "\n📦 Архівація файлів..."
      LoggerManager.log_info("[Engine] Архівація вихідних файлів")

      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
      archive_name = "books_export_#{timestamp}.zip"
      archive_path = File.join(MyApplicationKostyk.output_path, archive_name)

      Zip::File.open(archive_path, Zip::File::CREATE) do |zipfile|
        @output_files.each do |file_or_dir|
          if File.directory?(file_or_dir)
            # Додаємо директорію з усім вмістом
            Dir.glob("#{file_or_dir}/**/*").each do |file|
              next if File.directory?(file)

              entry_name = file.sub("#{MyApplicationKostyk.output_path}/", "")
              zipfile.add(entry_name, file)
            end
          elsif File.file?(file_or_dir)
            entry_name = File.basename(file_or_dir)
            zipfile.add(entry_name, file_or_dir)
          end
        end
      end

      puts "  ✓ Архів створено: #{archive_path}"
      LoggerManager.log_info("[Engine] Архів створено: #{archive_path}")

      # Спробуємо відправити архів (якщо Sidekiq доступний)
      schedule_archive_sending(archive_path)

      archive_path
    rescue StandardError => e
      LoggerManager.log_error("[Engine] Помилка архівації", e)
      puts "  ⚠ Помилка архівації: #{e.message}"
      nil
    end

    # Планує відправку архіву через Sidekiq
    # @param archive_path [String] шлях до архіву
    def schedule_archive_sending(archive_path)
      return unless defined?(ArchiveSenderWorker)

      email = @config.dig("email", "recipient") || ENV["ARCHIVE_EMAIL"]
      return unless email

      ArchiveSenderWorker.perform_async(archive_path, email)
      puts "  📧 Заплановано відправку на: #{email}"
      LoggerManager.log_info("[Engine] Заплановано відправку архіву на #{email}")
    rescue StandardError => e
      LoggerManager.log_warn("[Engine] Sidekiq недоступний: #{e.message}")
    end

    private

    # Ініціалізує логування
    def initialize_logging
      LoggerManager.setup(@config)
      puts "✓ Логування ініціалізовано"
      LoggerManager.log_info("[Engine] Логування ініціалізовано")
    end

    # Підключається до бази даних
    def connect_to_database
      LoggerManager.log_info("[Engine] Підключення до бази даних...")
      @db_connector = DatabaseConnector.new(@config)
      @db_connector.connect_to_database
      puts "✓ Підключено до бази даних (#{@db_connector.db_type})"
    rescue StandardError => e
      LoggerManager.log_error("[Engine] Помилка підключення до БД", e)
      @db_connector = nil
    end

    # Відключається від бази даних
    def disconnect_from_database
      return unless @db_connector&.connected?

      @db_connector.close_connection
      puts "✓ Відключено від бази даних"
      LoggerManager.log_info("[Engine] Відключено від бази даних")
    end

    # Перевіряє чи потрібно використовувати базу даних
    # @return [Boolean]
    def should_use_database?
      return false unless @configurator

      @configurator.enabled?(:run_save_to_sqlite) || @configurator.enabled?(:run_save_to_mongodb)
    end

    # Перевіряє наявність колекції книг
    def ensure_collection_exists
      return if @item_collection && !@item_collection.empty?

      # Якщо колекція порожня, генеруємо тестові дані
      LoggerManager.log_warn("[Engine] Колекція порожня, генеруємо тестові дані")
      @item_collection ||= ItemCollection.new
      @item_collection.generate_test_items(10)
    end

    # Перевіряє підключення до БД
    # @param db_type [String] тип бази даних
    def ensure_db_connected(db_type)
      return if @db_connector&.connected?

      connect_to_database
    end
  end
end

