# frozen_string_literal: true

require_relative "logger_manager"

module MyApplicationKostyk
  # Клас Configurator для управління конфігураційними параметрами
  # Дозволяє налаштовувати параметри парсингу та збереження даних
  class Configurator
    # Геттер для конфігураційного хешу
    attr_reader :config

    # Значення за замовчуванням для конфігурації
    DEFAULT_CONFIG = {
      # Парсинг
      run_website_parser: 0,        # Запуск парсингу сайту Books to Scrape
      parser_max_pages: 0,          # Максимальна кількість сторінок (0 = без обмежень)
      parser_delay: 1,              # Затримка між запитами (секунди)

      # Збереження даних
      run_save_to_csv: 0,           # Збереження даних в CSV форматі
      run_save_to_json: 0,          # Збереження даних в JSON форматі
      run_save_to_yaml: 0,          # Збереження даних в YAML форматі
      run_save_to_sqlite: 0,        # Збереження даних в базі даних SQLite
      run_save_to_mongodb: 0,       # Збереження даних в базі даних MongoDB

      # Шляхи
      output_directory: "output",   # Директорія для вихідних файлів
      logs_directory: "logs",       # Директорія для логів

      # Налаштування виводу
      verbose_mode: 0,              # Детальний вивід (0 = вимкнено, 1 = увімкнено)
      log_level: "INFO"             # Рівень логування
    }.freeze

    # Конструктор класу
    # Ініціалізує хеш @config зі значеннями за замовчуванням
    def initialize
      @config = DEFAULT_CONFIG.dup
      log_action("Configurator ініціалізовано зі значеннями за замовчуванням")
    end

    # Метод для налаштування конфігураційних параметрів
    # @param overrides [Hash] хеш з новими значеннями параметрів
    # @return [Hash] оновлений конфігураційний хеш
    def configure(overrides = {})
      overrides.each do |key, value|
        if @config.key?(key)
          old_value = @config[key]
          @config[key] = value
          log_action("Параметр #{key}: #{old_value} -> #{value}")
        else
          warn "[WARN] Невідомий конфігураційний ключ: #{key}"
          LoggerManager.log_warn("Спроба встановити невідомий ключ: #{key}")
        end
      end

      @config
    rescue StandardError => e
      LoggerManager.log_error("Помилка при конфігуруванні", e)
      @config
    end

    # Перевірка чи параметр увімкнено
    # @param key [Symbol] ключ параметра
    # @return [Boolean] true якщо значення > 0
    def enabled?(key)
      @config[key].to_i.positive?
    end

    # Отримання значення параметра
    # @param key [Symbol] ключ параметра
    # @return [Object] значення параметра або nil
    def get(key)
      @config[key]
    end

    # Встановлення значення параметра
    # @param key [Symbol] ключ параметра
    # @param value [Object] нове значення
    def set(key, value)
      configure(key => value)
    end

    # Скидання конфігурації до значень за замовчуванням
    # @return [Hash] скинутий конфігураційний хеш
    def reset!
      @config = DEFAULT_CONFIG.dup
      log_action("Конфігурацію скинуто до значень за замовчуванням")
      @config
    end

    # Виводить поточну конфігурацію
    def print_config
      puts "=" * 50
      puts "ПОТОЧНА КОНФІГУРАЦІЯ"
      puts "=" * 50
      @config.each do |key, value|
        status = value.is_a?(Integer) && value.positive? ? "✓" : "✗"
        status = "" unless value.is_a?(Integer)
        puts "  #{status} #{key}: #{value}"
      end
      puts "=" * 50
    end

    # Перетворення конфігурації в хеш
    # @return [Hash] копія конфігураційного хешу
    def to_h
      @config.dup
    end

    # Класовий метод для отримання списку доступних ключів
    # @return [Array<Symbol>] масив доступних ключів
    def self.available_methods
      DEFAULT_CONFIG.keys
    end

    # Класовий метод для отримання опису ключів
    # @return [Hash] хеш з описами ключів
    def self.keys_description
      {
        run_website_parser: "Запуск парсингу сайту Books to Scrape",
        parser_max_pages: "Максимальна кількість сторінок (0 = без обмежень)",
        parser_delay: "Затримка між запитами (секунди)",
        run_save_to_csv: "Збереження даних в CSV форматі",
        run_save_to_json: "Збереження даних в JSON форматі",
        run_save_to_yaml: "Збереження даних в YAML форматі",
        run_save_to_sqlite: "Збереження даних в базі даних SQLite",
        run_save_to_mongodb: "Збереження даних в базі даних MongoDB",
        output_directory: "Директорія для вихідних файлів",
        logs_directory: "Директорія для логів",
        verbose_mode: "Детальний вивід",
        log_level: "Рівень логування"
      }
    end

    # Виводить довідку по доступних ключах
    def self.print_help
      puts "=" * 60
      puts "ДОСТУПНІ КОНФІГУРАЦІЙНІ ПАРАМЕТРИ"
      puts "=" * 60
      keys_description.each do |key, description|
        default = DEFAULT_CONFIG[key]
        puts "  #{key}"
        puts "    Опис: #{description}"
        puts "    За замовчуванням: #{default}"
        puts
      end
      puts "=" * 60
    end

    private

    # Логування дій
    # @param message [String] повідомлення для логування
    def log_action(message)
      LoggerManager.log_info("[Configurator] #{message}")
    rescue StandardError
      # Якщо LoggerManager не ініціалізований
      puts "[INFO] #{message}" if @config[:verbose_mode].to_i.positive?
    end
  end
end

