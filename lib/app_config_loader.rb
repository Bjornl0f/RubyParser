# frozen_string_literal: true

require "yaml"
require "erb"
require "json"

module MyApplicationKostyk
  # Клас для завантаження конфігураційних даних з YAML файлів
  # Відповідає за централізоване управління налаштуваннями додатку
  class AppConfigLoader
    attr_reader :config_data, :loaded_libs

    # Системні бібліотеки для підключення
    SYSTEM_LIBS = %w[date fileutils logger].freeze

    def initialize
      @config_data = {}
      @loaded_libs = []
    end

    # Метод для автоматичного підключення бібліотек
    # Підключає системні бібліотеки та всі Ruby файли з директорії lib
    # @param libs_directory [String] шлях до директорії з локальними бібліотеками
    # @return [Array] масив підключених бібліотек
    def load_libs(libs_directory = nil)
      # Підключаємо системні бібліотеки
      SYSTEM_LIBS.each do |lib_name|
        load_system_lib(lib_name)
      end

      # Підключаємо локальні бібліотеки з директорії
      if libs_directory && Dir.exist?(libs_directory)
        load_local_libs(libs_directory)
      end

      @loaded_libs
    end

    private

    # Підключення системної бібліотеки
    # @param lib_name [String] назва бібліотеки
    def load_system_lib(lib_name)
      return if @loaded_libs.include?(lib_name)

      begin
        require lib_name
        @loaded_libs << lib_name
        puts "[INFO] Підключено системну бібліотеку: #{lib_name}"
      rescue LoadError => e
        warn "[WARN] Не вдалося підключити бібліотеку #{lib_name}: #{e.message}"
      end
    end

    # Підключення локальних бібліотек з директорії
    # @param directory [String] шлях до директорії
    def load_local_libs(directory)
      # Знаходимо всі Ruby файли в директорії
      ruby_files = Dir.glob(File.join(directory, "**", "*.rb"))

      ruby_files.each do |file_path|
        file_name = File.basename(file_path, ".rb")

        # Пропускаємо якщо файл вже підключений
        next if @loaded_libs.include?(file_name)

        # Пропускаємо main.rb та поточний файл
        next if %w[main app_config_loader].include?(file_name)

        begin
          require file_path
          @loaded_libs << file_name
          puts "[INFO] Підключено локальну бібліотеку: #{file_name}"
        rescue LoadError => e
          warn "[WARN] Не вдалося підключити файл #{file_path}: #{e.message}"
        rescue StandardError => e
          warn "[WARN] Помилка при підключенні #{file_path}: #{e.message}"
        end
      end
    end

    public

    # Метод для завантаження конфігурації
    # @param default_config_path [String] шлях до основного конфігураційного файлу
    # @param config_directory [String] директорія з додатковими YAML файлами
    # @yield [config_data] блок для обробки даних (опціонально)
    # @return [Hash] завантажені конфігураційні дані
    def config(default_config_path, config_directory = nil)
      # Завантажуємо основний конфігураційний файл
      @config_data = load_default_config(default_config_path)

      # Завантажуємо додаткові конфігураційні файли з директорії
      if config_directory && Dir.exist?(config_directory)
        additional_configs = load_config(config_directory)
        @config_data.merge!(additional_configs)
      end

      # Обробляємо дані через блок, якщо він переданий
      yield(@config_data) if block_given?

      @config_data
    end

    # Метод для виведення конфігураційних даних у форматі JSON
    # @return [String] форматований JSON рядок
    def pretty_print_config_data
      JSON.pretty_generate(@config_data)
    end

    # Виводить конфігурацію в консоль
    def print_config
      puts "=" * 60
      puts "КОНФІГУРАЦІЯ ДОДАТКУ"
      puts "=" * 60
      puts pretty_print_config_data
      puts "=" * 60
    end

    private

    # Приватний метод для завантаження основного конфігураційного файлу
    # Обробляє файл через ERB та YAML
    # @param file_path [String] шлях до файлу
    # @return [Hash] завантажені дані
    def load_default_config(file_path)
      unless File.exist?(file_path)
        raise ArgumentError, "Конфігураційний файл не знайдено: #{file_path}"
      end

      # Читаємо вміст файлу
      file_content = File.read(file_path)

      # Обробляємо через ERB для підтримки вбудованого Ruby коду
      erb_result = ERB.new(file_content).result

      # Парсимо YAML
      YAML.safe_load(erb_result, permitted_classes: [Symbol], permitted_symbols: [], aliases: true) || {}
    rescue Psych::SyntaxError => e
      raise "Помилка синтаксису YAML у файлі #{file_path}: #{e.message}"
    end

    # Приватний метод для завантаження всіх YAML файлів з директорії
    # @param directory [String] шлях до директорії
    # @return [Hash] об'єднані конфігураційні дані
    def load_config(directory)
      merged_config = {}

      # Знаходимо всі YAML файли в директорії
      yaml_files = Dir.glob(File.join(directory, "*.{yaml,yml}"))

      yaml_files.each do |file_path|
        # Пропускаємо default_config.yaml, щоб не завантажувати його повторно
        next if File.basename(file_path) == "default_config.yaml"

        begin
          file_content = File.read(file_path)
          erb_result = ERB.new(file_content).result
          file_config = YAML.safe_load(erb_result, permitted_classes: [Symbol], permitted_symbols: [], aliases: true) || {}

          # Об'єднуємо конфігурації
          merged_config.merge!(file_config)
        rescue Psych::SyntaxError => e
          warn "Попередження: Помилка синтаксису YAML у файлі #{file_path}: #{e.message}"
        rescue StandardError => e
          warn "Попередження: Не вдалося завантажити файл #{file_path}: #{e.message}"
        end
      end

      merged_config
    end
  end
end

