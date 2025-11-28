# frozen_string_literal: true

# Головний файл програми для парсингу веб-сайтів
# Автор: Стефан Костик

require "nokogiri"
require "httparty"
require "mechanize"

require_relative "my_application_kostyk"
require_relative "app_config_loader"
require_relative "logger_manager"

puts "=" * 60
puts "Ruby Web Parser - #{MyApplicationKostyk::VERSION}"
puts "=" * 60

# Крок 1: Створення екземпляру завантажувача конфігурацій
config_loader = MyApplicationKostyk::AppConfigLoader.new

# Крок 2: Автоматичне підключення бібліотек
puts "\n--- Підключення бібліотек ---"
libs_path = File.join(MyApplicationKostyk.root, "lib")
config_loader.load_libs(libs_path)
puts "Підключено бібліотек: #{config_loader.loaded_libs.size}"

# Крок 3: Завантаження конфігурацій
puts "\n--- Завантаження конфігурацій ---"
config_path = File.join(MyApplicationKostyk.config_path, "default_config.yaml")
config_loader.config(config_path, MyApplicationKostyk.config_path)

# Крок 4: Перевірка завантаження конфігурацій (вивід у форматі JSON)
puts "\n--- Завантажені конфігурації (JSON) ---"
puts config_loader.pretty_print_config_data

# Крок 5: Налаштування логування
puts "\n--- Налаштування логування ---"
MyApplicationKostyk::LoggerManager.setup(config_loader.config_data)

# Крок 6: Перевірка логування
puts "\n--- Перевірка логування ---"
MyApplicationKostyk::LoggerManager.log_info("Тестове інформаційне повідомлення")
MyApplicationKostyk::LoggerManager.log_warn("Тестове попередження")
MyApplicationKostyk::LoggerManager.log_processed_file("test_file.rb", "Файл успішно оброблено")

# Тест логування помилки
begin
  raise StandardError, "Тестова помилка для перевірки логування"
rescue StandardError => e
  MyApplicationKostyk::LoggerManager.log_error("Виникла тестова помилка", e)
end

puts "\n" + "=" * 60
puts "Ініціалізація завершена успішно!"
puts "Перевірте файли логів у директорії: #{MyApplicationKostyk.logs_path}"
puts "=" * 60
