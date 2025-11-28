# frozen_string_literal: true

require "logger"
require "fileutils"

module MyApplicationKostyk
  # Клас для управління логуванням у додатку
  # Забезпечує централізоване логування на основі конфігурації з YAML файлів
  class LoggerManager
    class << self
      attr_reader :logger, :error_logger

      # Ініціалізація логера на основі конфігураційних даних
      # @param config [Hash] хеш з конфігураційними даними з YAML файлів
      def setup(config)
        logging_config = config["logging"] || {}

        # Отримуємо параметри з конфігурації
        directory = logging_config["log_directory"] || logging_config["directory"] || "logs"
        level = logging_config["level"] || "INFO"
        files = logging_config["files"] || {}

        # Створюємо директорію для логів, якщо вона не існує
        FileUtils.mkdir_p(directory) unless Dir.exist?(directory)

        # Назви файлів логів
        app_log_file = files["application"] || files["application_log"] || "application.log"
        error_log_file = files["error"] || files["error_log"] || "error.log"

        # Ініціалізуємо основний логер
        @logger = create_logger(
          File.join(directory, app_log_file),
          level
        )

        # Ініціалізуємо логер для помилок
        @error_logger = create_logger(
          File.join(directory, error_log_file),
          "ERROR"
        )

        log_info("LoggerManager ініціалізовано успішно")
        log_info("Рівень логування: #{level}")
        log_info("Директорія логів: #{directory}")
      end

      # Логування обробленого файлу
      # @param file_name [String] назва обробленого файлу
      # @param details [String] додаткові деталі (опціонально)
      def log_processed_file(file_name, details = nil)
        message = "Оброблено файл: #{file_name}"
        message += " | #{details}" if details
        log_info(message)
      end

      # Логування помилки
      # @param error_message [String] повідомлення про помилку
      # @param exception [Exception] об'єкт винятку (опціонально)
      def log_error(error_message, exception = nil)
        full_message = error_message
        if exception
          full_message += " | Exception: #{exception.class} - #{exception.message}"
          full_message += "\nBacktrace: #{exception.backtrace&.first(5)&.join("\n")}"
        end

        @logger&.error(full_message)
        @error_logger&.error(full_message)

        # Також виводимо в консоль
        warn "[ERROR] #{full_message}"
      end

      # Логування інформаційного повідомлення
      # @param message [String] повідомлення
      def log_info(message)
        @logger&.info(message)
        puts "[INFO] #{message}"
      end

      # Логування попередження
      # @param message [String] повідомлення
      def log_warn(message)
        @logger&.warn(message)
        warn "[WARN] #{message}"
      end

      # Логування дебаг повідомлення
      # @param message [String] повідомлення
      def log_debug(message)
        @logger&.debug(message)
      end

      private

      # Створення екземпляру логера
      # @param file_path [String] шлях до файлу логу
      # @param level [String] рівень логування
      # @return [Logger] екземпляр логера
      def create_logger(file_path, level)
        logger = Logger.new(file_path)
        logger.level = parse_log_level(level)
        logger.formatter = proc do |severity, datetime, _progname, msg|
          "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity}: #{msg}\n"
        end
        logger
      end

      # Парсинг рівня логування з рядка
      # @param level [String] рівень логування (DEBUG, INFO, WARN, ERROR, FATAL)
      # @return [Integer] константа рівня логування
      def parse_log_level(level)
        case level.to_s.upcase
        when "DEBUG"
          Logger::DEBUG
        when "INFO"
          Logger::INFO
        when "WARN"
          Logger::WARN
        when "ERROR"
          Logger::ERROR
        when "FATAL"
          Logger::FATAL
        else
          Logger::INFO
        end
      end
    end
  end
end

