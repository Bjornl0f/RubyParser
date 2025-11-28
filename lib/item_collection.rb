# frozen_string_literal: true

require "json"
require "csv"
require "yaml"
require "fileutils"

require_relative "item"
require_relative "item_container"
require_relative "logger_manager"

module MyApplicationKostyk
  # Клас ItemCollection для управління колекцією книг
  # Використовує модуль ItemContainer та Enumerable для розширення функціональності
  class ItemCollection
    include ItemContainer
    include Enumerable

    # Геттер для масиву книг
    attr_reader :items

    # Конструктор класу
    # @param items [Array<Item>] початковий масив книг (опціонально)
    def initialize(items = [])
      @items = items
      self.class.increment_instances_count
      LoggerManager.log_info("Створено ItemCollection (#{@items.size} книг)")
    rescue StandardError
      # Якщо LoggerManager ще не ініціалізований
      nil
    end

    # ============================================
    # Enumerable методи
    # ============================================

    # Основний метод для Enumerable - ітерація по книгах
    # @yield [Item] блок для кожної книги
    def each(&block)
      @items.each(&block)
    end

    # Кількість книг у колекції або за умовою
    # @param condition [Proc] умова (опціонально)
    # @return [Integer] кількість книг
    def count(condition = nil, &block)
      if block_given?
        @items.count(&block)
      elsif condition
        @items.count(condition)
      else
        @items.size
      end
    end

    # Кількість книг (alias для size)
    def size
      @items.size
    end

    # Перевірка чи колекція порожня
    # @return [Boolean]
    def empty?
      @items.empty?
    end

    # Перетворює елементи колекції
    # @yield [Item] блок для кожної книги
    # @return [Array] результати перетворення
    def map(&block)
      @items.map(&block)
    end

    # Вибирає книги за умовою
    # @yield [Item] блок з умовою
    # @return [Array<Item>] книги що відповідають умові
    def select(&block)
      @items.select(&block)
    end

    # Вибирає книги що НЕ відповідають умові
    # @yield [Item] блок з умовою
    # @return [Array<Item>] книги що не відповідають умові
    def reject(&block)
      @items.reject(&block)
    end

    # Знаходить першу книгу за умовою
    # @yield [Item] блок з умовою
    # @return [Item, nil] перша книга або nil
    def find(&block)
      @items.find(&block)
    end
    alias detect find

    # Зводить колекцію до одного значення
    # @param initial [Object] початкове значення
    # @yield [accumulator, Item] блок для акумуляції
    # @return [Object] результат
    def reduce(initial = nil, &block)
      if initial
        @items.reduce(initial, &block)
      else
        @items.reduce(&block)
      end
    end
    alias inject reduce

    # Перевіряє чи всі книги відповідають умові
    # @yield [Item] блок з умовою
    # @return [Boolean]
    def all?(&block)
      @items.all?(&block)
    end

    # Перевіряє чи хоча б одна книга відповідає умові
    # @yield [Item] блок з умовою
    # @return [Boolean]
    def any?(&block)
      @items.any?(&block)
    end

    # Перевіряє чи жодна книга не відповідає умові
    # @yield [Item] блок з умовою
    # @return [Boolean]
    def none?(&block)
      @items.none?(&block)
    end

    # Сортує книги
    # @yield [Item, Item] блок для порівняння (опціонально)
    # @return [Array<Item>] відсортовані книги
    def sort(&block)
      if block_given?
        @items.sort(&block)
      else
        @items.sort
      end
    end

    # Сортує книги за атрибутом
    # @param attribute [Symbol] атрибут для сортування
    # @return [Array<Item>] відсортовані книги
    def sort_by_attribute(attribute)
      @items.sort_by { |item| item.send(attribute) }
    end

    # Повертає унікальні книги (за title)
    # @return [Array<Item>] унікальні книги
    def uniq
      @items.uniq { |item| item.title }
    end

    # ============================================
    # Генерація тестових даних
    # ============================================

    # Генерує тестові книги та додає їх до колекції
    # @param count [Integer] кількість книг для генерації
    # @return [Array<Item>] згенеровані книги
    def generate_test_items(count = 10)
      LoggerManager.log_info("Генерація #{count} тестових книг...")

      generated = []
      count.times do
        item = Item.generate_fake
        add_item(item)
        generated << item
      end

      LoggerManager.log_info("Згенеровано #{count} тестових книг. Всього в колекції: #{@items.size}")
      generated
    rescue StandardError => e
      LoggerManager.log_error("Помилка генерації тестових даних", e)
      generated
    end

    # ============================================
    # Пошук та фільтрація
    # ============================================

    # Пошук книг за категорією
    # @param category [String] назва категорії
    # @return [Array<Item>] масив книг категорії
    def find_by_category(category)
      result = @items.select { |item| item.category.downcase == category.downcase }
      LoggerManager.log_info("Знайдено #{result.size} книг у категорії '#{category}'")
      result
    rescue StandardError
      @items.select { |item| item.category.downcase == category.downcase }
    end

    # Пошук книг за ціновим діапазоном
    # @param min_price [Float] мінімальна ціна
    # @param max_price [Float] максимальна ціна
    # @return [Array<Item>] масив книг в діапазоні
    def find_by_price_range(min_price, max_price)
      result = @items.select { |item| item.price >= min_price && item.price <= max_price }
      LoggerManager.log_info("Знайдено #{result.size} книг у ціновому діапазоні £#{min_price}-£#{max_price}")
      result
    rescue StandardError
      @items.select { |item| item.price >= min_price && item.price <= max_price }
    end

    # Пошук книг за рейтингом
    # @param min_rating [Integer] мінімальний рейтинг (1-5)
    # @return [Array<Item>] масив книг з рейтингом >= min_rating
    def find_by_rating(min_rating)
      result = @items.select { |item| item.rating >= min_rating }
      LoggerManager.log_info("Знайдено #{result.size} книг з рейтингом >= #{min_rating}")
      result
    rescue StandardError
      @items.select { |item| item.rating >= min_rating }
    end

    # ============================================
    # Статистика
    # ============================================

    # Загальна вартість всіх книг
    # @return [Float] сума цін
    def total_price
      @items.reduce(0) { |sum, item| sum + item.price }
    end

    # Середня ціна книги
    # @return [Float] середня ціна
    def average_price
      return 0 if @items.empty?

      total_price / @items.size
    end

    # Середній рейтинг
    # @return [Float] середній рейтинг
    def average_rating
      return 0 if @items.empty?

      @items.reduce(0) { |sum, item| sum + item.rating }.to_f / @items.size
    end

    # Статистика по категоріях
    # @return [Hash] кількість книг по категоріях
    def categories_stats
      @items.group_by(&:category).transform_values(&:count)
    end

    # ============================================
    # Збереження у файли
    # ============================================

    # Зберігає інформацію у текстовому файлі
    # @param file_path [String] шлях до файлу
    def save_to_file(file_path)
      ensure_directory_exists(file_path)

      File.open(file_path, "w") do |file|
        file.puts "=" * 60
        file.puts "КОЛЕКЦІЯ КНИГ - Books to Scrape"
        file.puts "Дата: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
        file.puts "Кількість книг: #{@items.size}"
        file.puts "Загальна вартість: £#{total_price.round(2)}"
        file.puts "Середня ціна: £#{average_price.round(2)}"
        file.puts "=" * 60
        file.puts

        @items.each_with_index do |item, index|
          file.puts "#{index + 1}. #{item.title}"
          file.puts "   Ціна: £#{item.price}"
          file.puts "   Рейтинг: #{item.rating}/5"
          file.puts "   Категорія: #{item.category}"
          file.puts "   Наявність: #{item.availability}"
          file.puts "   URL: #{item.url}"
          file.puts
        end
      end

      LoggerManager.log_processed_file(file_path, "Збережено #{@items.size} книг у TXT")
    rescue StandardError => e
      LoggerManager.log_error("Помилка збереження у TXT", e)
      raise
    end

    # Зберігає інформацію у форматі JSON
    # @param file_path [String] шлях до файлу
    def save_to_json(file_path)
      ensure_directory_exists(file_path)

      data = {
        metadata: {
          source: "Books to Scrape",
          exported_at: Time.now.iso8601,
          total_items: @items.size,
          total_price: total_price.round(2),
          average_price: average_price.round(2),
          average_rating: average_rating.round(2)
        },
        books: @items.map(&:to_h)
      }

      File.write(file_path, JSON.pretty_generate(data))
      LoggerManager.log_processed_file(file_path, "Збережено #{@items.size} книг у JSON")
    rescue StandardError => e
      LoggerManager.log_error("Помилка збереження у JSON", e)
      raise
    end

    # Зберігає інформацію у форматі CSV
    # @param file_path [String] шлях до файлу
    def save_to_csv(file_path)
      ensure_directory_exists(file_path)

      headers = %w[title price rating availability category url image_path description]

      CSV.open(file_path, "w", write_headers: true, headers: headers) do |csv|
        @items.each do |item|
          csv << [
            item.title,
            item.price,
            item.rating,
            item.availability,
            item.category,
            item.url,
            item.image_path,
            item.description
          ]
        end
      end

      LoggerManager.log_processed_file(file_path, "Збережено #{@items.size} книг у CSV")
    rescue StandardError => e
      LoggerManager.log_error("Помилка збереження у CSV", e)
      raise
    end

    # Зберігає інформацію у форматі YAML (кожна книга в окремому файлі)
    # @param directory [String] шлях до директорії
    def save_to_yml(directory)
      FileUtils.mkdir_p(directory) unless Dir.exist?(directory)

      @items.each do |item|
        # Генеруємо slug для імені файлу
        slug = item.title.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/^_|_$/, "")
        file_path = File.join(directory, "#{slug}.yaml")

        book_data = {
          "book" => {
            "title" => item.title,
            "price" => item.price,
            "rating" => item.rating,
            "availability" => item.availability,
            "category" => item.category,
            "url" => item.url,
            "image_path" => item.image_path,
            "description" => item.description,
            "exported_at" => Time.now.iso8601
          }
        }

        File.write(file_path, book_data.to_yaml)
      end

      LoggerManager.log_processed_file(directory, "Збережено #{@items.size} книг у YAML файли")
    rescue StandardError => e
      LoggerManager.log_error("Помилка збереження у YAML", e)
      raise
    end

    # ============================================
    # Завантаження з файлів
    # ============================================

    # Завантаження книг з JSON файлу
    # @param file_path [String] шлях до файлу
    # @return [ItemCollection] нова колекція
    def self.load_from_json(file_path)
      LoggerManager.log_info("Завантаження книг з JSON: #{file_path}")

      data = JSON.parse(File.read(file_path))
      books_data = data["books"] || data

      items = books_data.map do |book_hash|
        Item.new(
          title: book_hash["title"],
          price: book_hash["price"],
          rating: book_hash["rating"],
          availability: book_hash["availability"],
          category: book_hash["category"],
          url: book_hash["url"],
          image_path: book_hash["image_path"],
          description: book_hash["description"]
        )
      end

      LoggerManager.log_info("Завантажено #{items.size} книг з JSON")
      new(items)
    rescue StandardError => e
      LoggerManager.log_error("Помилка завантаження з JSON", e)
      raise
    end

    # Завантаження книг з CSV файлу
    # @param file_path [String] шлях до файлу
    # @return [ItemCollection] нова колекція
    def self.load_from_csv(file_path)
      LoggerManager.log_info("Завантаження книг з CSV: #{file_path}")

      items = []

      CSV.foreach(file_path, headers: true) do |row|
        items << Item.new(
          title: row["title"],
          price: row["price"].to_f,
          rating: row["rating"].to_i,
          availability: row["availability"],
          category: row["category"],
          url: row["url"],
          image_path: row["image_path"],
          description: row["description"]
        )
      end

      LoggerManager.log_info("Завантажено #{items.size} книг з CSV")
      new(items)
    rescue StandardError => e
      LoggerManager.log_error("Помилка завантаження з CSV", e)
      raise
    end

    private

    # Переконується що директорія існує
    # @param file_path [String] шлях до файлу
    def ensure_directory_exists(file_path)
      dir = File.dirname(file_path)
      FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
    end
  end
end
