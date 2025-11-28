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
require_relative "item_collection"

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

# Крок 11: Тестування класу ItemCollection
puts "\n--- Тестування класу ItemCollection ---"

# Створення колекції та генерація тестових даних
collection = MyApplicationKostyk::ItemCollection.new

puts "\n11. Генерація тестових книг (generate_test_items):"
collection.generate_test_items(10)
puts "  Згенеровано книг: #{collection.size}"

# Виклик show_all_items через method_missing
puts "\n12. Метод show_all_items (method_missing):"
collection.show_all_items

# Тестування Enumerable методів
puts "\n13. Тестування Enumerable методів:"

# map - отримати всі назви
puts "\n  a) map - отримати всі назви:"
titles = collection.map(&:title)
puts "     Перші 3: #{titles.first(3).join(', ')}"

# select - книги дорожче £30
puts "\n  b) select - книги дорожче £30:"
expensive = collection.select { |book| book.price > 30 }
puts "     Знайдено: #{expensive.size} книг"

# reject - книги БЕЗ рейтингу 5
puts "\n  c) reject - книги без рейтингу 5:"
not_five_star = collection.reject { |book| book.rating == 5 }
puts "     Знайдено: #{not_five_star.size} книг"

# find - перша книга з рейтингом >= 4
puts "\n  d) find - перша книга з рейтингом >= 4:"
good_book = collection.find { |book| book.rating >= 4 }
puts "     Знайдено: #{good_book&.title || 'Не знайдено'}"

# reduce - загальна вартість
puts "\n  e) reduce - загальна вартість:"
total = collection.reduce(0) { |sum, book| sum + book.price }
puts "     Загальна вартість: £#{total.round(2)}"

# all? - чи всі книги в наявності
puts "\n  f) all? - чи всі книги в наявності:"
all_in_stock = collection.all? { |book| book.availability == "In stock" }
puts "     Всі в наявності: #{all_in_stock}"

# any? - чи є книги дорожче £50
puts "\n  g) any? - чи є книги дорожче £50:"
has_expensive = collection.any? { |book| book.price > 50 }
puts "     Є дорогі книги: #{has_expensive}"

# none? - чи немає книг з ціною 0
puts "\n  h) none? - чи немає безкоштовних книг:"
no_free = collection.none? { |book| book.price == 0 }
puts "     Немає безкоштовних: #{no_free}"

# count - кількість книг з рейтингом 5
puts "\n  i) count - книги з рейтингом 5:"
five_star_count = collection.count { |book| book.rating == 5 }
puts "     Кількість: #{five_star_count}"

# sort - сортування за ціною
puts "\n  j) sort - топ-3 найдешевші книги:"
sorted = collection.sort
sorted.first(3).each { |b| puts "     £#{b.price} - #{b.title}" }

# uniq - унікальні книги
puts "\n  k) uniq - унікальні книги:"
unique = collection.uniq
puts "     Унікальних: #{unique.size}"

# Статистика
puts "\n14. Статистика колекції:"
puts "  Загальна вартість: £#{collection.total_price.round(2)}"
puts "  Середня ціна: £#{collection.average_price.round(2)}"
puts "  Середній рейтинг: #{collection.average_rating.round(2)}/5"
puts "  Категорії: #{collection.categories_stats}"

# Інформація про клас
puts "\n15. Інформація про клас (class_info):"
info = MyApplicationKostyk::ItemCollection.class_info
puts "  Назва: #{info[:name]}"
puts "  Версія: #{info[:version]}"
puts "  Кількість екземплярів: #{info[:instances_count]}"

# Збереження у різних форматах
puts "\n16. Збереження колекції у різних форматах:"
collection.save_to_file("output/books_collection.txt")
puts "  ✓ Збережено у TXT: output/books_collection.txt"

collection.save_to_json("output/books_collection.json")
puts "  ✓ Збережено у JSON: output/books_collection.json"

collection.save_to_csv("output/books_collection.csv")
puts "  ✓ Збережено у CSV: output/books_collection.csv"

collection.save_to_yml("output/books_yaml")
puts "  ✓ Збережено у YAML: output/books_yaml/"

puts "\n" + "=" * 60
puts "Ініціалізація завершена успішно!"
puts "Перевірте файли логів у директорії: #{MyApplicationKostyk.logs_path}"
puts "=" * 60
