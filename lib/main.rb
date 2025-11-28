# frozen_string_literal: true

# Головний файл програми для парсингу веб-сайтів
# Автор: Стефан Костик

require "nokogiri"
require "httparty"
require "mechanize"

require_relative "my_application_kostyk"
require_relative "app_config_loader"
require_relative "logger_manager"
require_relative "item"

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

# Крок 7: Тестування класу Item
puts "\n--- Тестування класу Item ---"

# Створення книги з базовими атрибутами
book1 = MyApplicationKostyk::Item.new(
  title: "A Light in the Attic",
  price: 51.77,
  rating: 3,
  availability: "In stock",
  category: "Poetry",
  url: "http://books.toscrape.com/catalogue/a-light-in-the-attic_1000/index.html",
  image_path: "products/poetry/a_light_in_the_attic.jpg"
)

puts "\n1. Метод to_s:"
puts book1.to_s

puts "\n2. Метод to_h:"
puts book1.to_h.inspect

puts "\n3. Метод inspect:"
puts book1.inspect

# Створення книги з використанням блоку
puts "\n4. Створення з блоком:"
book2 = MyApplicationKostyk::Item.new(title: "Sharp Objects", price: 47.82) do |item|
  item.rating = 4
  item.category = "Mystery"
  item.availability = "In stock"
  item.description = "A psychological thriller by Gillian Flynn"
  item.image_path = "products/mystery/sharp_objects.jpg"
end
puts book2.inspect

# Тест парсингу ціни та рейтингу
puts "\n5. Парсинг даних:"
puts "  Ціна '£51.77' -> #{MyApplicationKostyk::Item.parse_price('£51.77')}"
puts "  Рейтинг 'Three' -> #{MyApplicationKostyk::Item.parse_rating('Three')}"

# Тест методу update з блоком
puts "\n6. Метод update з блоком:"
book1.update do |item|
  item.title = "A Light in the Attic (Updated)"
  item.price = 55.00
end
puts book1.inspect

# Тест методу info (alias для to_s)
puts "\n7. Метод info (alias для to_s):"
puts book2.info

# Тест генерації фіктивних даних з Faker
puts "\n8. Генерація фіктивних книг (Faker):"
3.times do |i|
  fake_book = MyApplicationKostyk::Item.generate_fake
  puts "  #{i + 1}. #{fake_book.inspect}"
end

# Тест Comparable (порівняння за ціною)
puts "\n9. Порівняння книг (Comparable):"
book3 = MyApplicationKostyk::Item.new(title: "Cheap Book", price: 10.00)
book4 = MyApplicationKostyk::Item.new(title: "Expensive Book", price: 99.99)

puts "  book3 (£#{book3.price}) < book4 (£#{book4.price}): #{book3 < book4}"
puts "  book3 (£#{book3.price}) > book4 (£#{book4.price}): #{book3 > book4}"
puts "  book3 (£#{book3.price}) == book4 (£#{book4.price}): #{book3 == book4}"

# Сортування книг за ціною
puts "\n10. Сортування книг за ціною:"
books = [book1, book2, book3, book4]
sorted_books = books.sort
sorted_books.each do |book|
  puts "  £#{book.price} - #{book.title}"
end

puts "\n" + "=" * 60
puts "Ініціалізація завершена успішно!"
puts "Перевірте файли логів у директорії: #{MyApplicationKostyk.logs_path}"
puts "=" * 60
