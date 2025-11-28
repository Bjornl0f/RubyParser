# frozen_string_literal: true

# ============================================
# Ruby Web Parser - Головний файл програми
# Точка входу для додатку
# Автор: Стефан Костик
# Сайт для парсингу: https://books.toscrape.com/
# ============================================

# Завантаження базових бібліотек
require_relative "my_application_kostyk"
require_relative "app_config_loader"
require_relative "logger_manager"
require_relative "configurator"
require_relative "engine"

module MyApplicationKostyk
  # Головний клас для запуску додатку
  class Main
    class << self
      # Запускає додаток з параметрами конфігурації
      # @param config_params [Hash] параметри конфігурації (опціонально)
      def run(config_params = nil)
        puts banner
        puts "Версія: #{VERSION}"
        puts "=" * 60

        begin
          # Крок 1: Завантаження бібліотек
          load_libraries

          # Крок 2: Завантаження конфігурації
          config = load_configuration

          # Крок 3: Налаштування параметрів через Configurator
          params = setup_configurator(config_params)

          # Крок 4: Запуск Engine
          run_engine(params)

          puts "\n" + "=" * 60
          puts "✓ Програма завершила роботу успішно!"
          puts "=" * 60
        rescue StandardError => e
          handle_error(e)
          exit(1)
        end
      end

      # Виводить банер програми
      # @return [String] банер
      def banner
        <<~BANNER

          ╔══════════════════════════════════════════════════════════╗
          ║          RUBY WEB PARSER - BOOKS TO SCRAPE               ║
          ║              Парсер книжкового магазину                  ║
          ╚══════════════════════════════════════════════════════════╝

        BANNER
      end

      private

      # Завантажує всі необхідні бібліотеки
      def load_libraries
        puts "\n📚 Завантаження бібліотек..."

        @config_loader = AppConfigLoader.new
        libs_path = File.join(MyApplicationKostyk.root, "lib")
        @config_loader.load_libs(libs_path)

        puts "  ✓ Завантажено #{@config_loader.loaded_libs.size} бібліотек"
        LoggerManager.log_info("[Main] Бібліотеки завантажено: #{@config_loader.loaded_libs.join(', ')}")
      rescue StandardError => e
        raise "Помилка завантаження бібліотек: #{e.message}"
      end

      # Завантажує конфігурацію з YAML файлів
      # @return [Hash] завантажена конфігурація
      def load_configuration
        puts "\n⚙️  Завантаження конфігурації..."

        config_path = File.join(MyApplicationKostyk.config_path, "default_config.yaml")
        @config_loader.config(config_path, MyApplicationKostyk.config_path)

        # Ініціалізуємо логування
        LoggerManager.setup(@config_loader.config_data)

        puts "  ✓ Конфігурацію завантажено"
        LoggerManager.log_info("[Main] Конфігурація завантажена успішно")

        @config_loader.config_data
      rescue StandardError => e
        raise "Помилка завантаження конфігурації: #{e.message}"
      end

      # Налаштовує Configurator з параметрами
      # @param custom_params [Hash] користувацькі параметри
      # @return [Hash] параметри для Engine
      def setup_configurator(custom_params)
        puts "\n🔧 Налаштування параметрів..."

        @configurator = Configurator.new

        # Параметри за замовчуванням для повного запуску
        default_params = {
          run_website_parser: 1,
          run_save_to_csv: 1,
          run_save_to_json: 1,
          run_save_to_yaml: 1,
          run_save_to_sqlite: 1,
          run_save_to_mongodb: 0,
          parser_max_pages: 2,
          use_threads: 1,
          verbose_mode: 1
        }

        # Якщо передано користувацькі параметри - використовуємо їх
        params = custom_params || default_params
        @configurator.configure(params)

        puts "  ✓ Параметри налаштовано"
        @configurator.print_config if params[:verbose_mode]&.positive?

        LoggerManager.log_info("[Main] Параметри налаштовано")
        params
      end

      # Запускає Engine з параметрами
      # @param params [Hash] параметри для виконання
      def run_engine(params)
        puts "\n🚀 Запуск Engine..."
        LoggerManager.log_info("[Main] Запуск Engine")

        engine = Engine.new
        engine.run(params)
      end

      # Обробляє помилки
      # @param error [StandardError] помилка
      def handle_error(error)
        puts "\n" + "=" * 60
        puts "❌ ПОМИЛКА: #{error.message}"
        puts "=" * 60

        if ENV["DEBUG"]
          puts "\nДеталі помилки:"
          puts error.backtrace.first(10).join("\n")
        end

        LoggerManager.log_error("[Main] Критична помилка", error)
      end
    end
  end
end

# ============================================
# Запуск програми, якщо файл виконується напряму
# ============================================
if __FILE__ == $PROGRAM_NAME
  # Парсинг аргументів командного рядка
  params = {}

  ARGV.each do |arg|
    case arg
    when "--help", "-h"
      puts MyApplicationKostyk::Main.banner
      puts "Використання: ruby main.rb [опції]"
      puts ""
      puts "Опції:"
      puts "  --help, -h          Показати цю довідку"
      puts "  --pages=N           Кількість сторінок для парсингу (за замовчуванням: 2)"
      puts "  --no-threads        Вимкнути багатопоточність"
      puts "  --csv-only          Зберегти тільки у CSV"
      puts "  --json-only         Зберегти тільки у JSON"
      puts "  --no-db             Не зберігати в базу даних"
      puts "  --test              Тестовий режим (1 сторінка, без БД)"
      puts ""
      exit(0)
    when /--pages=(\d+)/
      params[:parser_max_pages] = ::Regexp.last_match(1).to_i
    when "--no-threads"
      params[:use_threads] = 0
    when "--csv-only"
      params[:run_save_to_csv] = 1
      params[:run_save_to_json] = 0
      params[:run_save_to_yaml] = 0
    when "--json-only"
      params[:run_save_to_json] = 1
      params[:run_save_to_csv] = 0
      params[:run_save_to_yaml] = 0
    when "--no-db"
      params[:run_save_to_sqlite] = 0
      params[:run_save_to_mongodb] = 0
    when "--test"
      params = {
        run_website_parser: 1,
        run_save_to_csv: 1,
        run_save_to_json: 1,
        run_save_to_yaml: 0,
        run_save_to_sqlite: 0,
        run_save_to_mongodb: 0,
        parser_max_pages: 1,
        use_threads: 0,
        verbose_mode: 1
      }
    end
  end

  # Запуск з параметрами або без
  MyApplicationKostyk::Main.run(params.empty? ? nil : params)
end
