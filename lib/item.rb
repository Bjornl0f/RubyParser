# frozen_string_literal: true

require_relative "logger_manager"
require "faker"

module MyApplicationKostyk
  # Клас Item для представлення книги з сайту Books to Scrape
  # Містить атрибути та методи для роботи з даними книги
  # Реалізує модуль Comparable для порівняння об'єктів
  class Item
    include Comparable

    # Геттери та сеттери для всіх атрибутів
    attr_accessor :title, :price, :rating, :availability, :category, :url, :image_path, :description

    # Категорії книг з сайту Books to Scrape
    BOOK_CATEGORIES = %w[
      Travel Mystery Historical\ Fiction Sequential\ Art Classics
      Philosophy Romance Fiction Childrens Religion Nonfiction
      Music Science\ Fiction Sports Fantasy Young\ Adult Science
      Poetry Horror History Biography Thriller Crime
    ].freeze

    # Значення за замовчуванням для атрибутів
    DEFAULT_VALUES = {
      title: "Невідома книга",
      price: 0.0,
      rating: 0,
      availability: "Unknown",
      category: "Uncategorized",
      url: "",
      image_path: "",
      description: ""
    }.freeze

    # Конструктор класу
    # @param attributes [Hash] хеш з параметрами для ініціалізації
    # @yield [self] блок для додаткового налаштування об'єкта
    def initialize(attributes = {})
      # Ініціалізація атрибутів зі значеннями за замовчуванням
      @title = attributes.fetch(:title, DEFAULT_VALUES[:title])
      @price = attributes.fetch(:price, DEFAULT_VALUES[:price])
      @rating = attributes.fetch(:rating, DEFAULT_VALUES[:rating])
      @availability = attributes.fetch(:availability, DEFAULT_VALUES[:availability])
      @category = attributes.fetch(:category, DEFAULT_VALUES[:category])
      @url = attributes.fetch(:url, DEFAULT_VALUES[:url])
      @image_path = attributes.fetch(:image_path, DEFAULT_VALUES[:image_path])
      @description = attributes.fetch(:description, DEFAULT_VALUES[:description])

      # Виконання блоку для додаткового налаштування, якщо він переданий
      yield(self) if block_given?

      # Логування створення об'єкта
      log_initialization
    end

    # Метод update для зміни атрибутів через блок
    # @yield [self] блок для зміни атрибутів
    # @return [self] повертає об'єкт для ланцюжкових викликів
    def update
      yield(self) if block_given?
      LoggerManager.log_info("Оновлено Item: #{@title}")
      self
    rescue StandardError => e
      LoggerManager.log_error("Помилка при оновленні Item", e)
      self
    end

    # Метод to_s для формування рядкового представлення об'єкта
    # Проходить по всіх атрибутах та їх значеннях
    # @return [String] рядкове представлення об'єкта
    def to_s
      output = "=== Book Item ===\n"
      instance_variables.each do |var|
        attr_name = var.to_s.delete("@")
        attr_value = instance_variable_get(var)
        output += "  #{attr_name}: #{attr_value}\n"
      end
      output += "================="
      output
    end

    # Псевдонім info для методу to_s
    alias_method :info, :to_s

    # Метод to_h для формування хешу на базі атрибутів класу
    # Використовує динамічний підхід для незалежності від назв атрибутів
    # @return [Hash] хеш з атрибутами об'єкта
    def to_h
      instance_variables.each_with_object({}) do |var, hash|
        attr_name = var.to_s.delete("@").to_sym
        hash[attr_name] = instance_variable_get(var)
      end
    end

    # Метод inspect для відображення інформації про об'єкт
    # @return [String] інформація про об'єкт у зручному форматі
    def inspect
      "#<#{self.class.name} title=#{@title.inspect} price=#{@price} rating=#{@rating} category=#{@category.inspect}>"
    end

    # Оператор порівняння для модуля Comparable
    # Порівнює книги за ціною
    # @param other [Item] інший об'єкт Item
    # @return [Integer] -1, 0 або 1
    def <=>(other)
      return nil unless other.is_a?(Item)

      @price <=> other.price
    end

    # Метод для створення об'єкта Item з фіктивними даними
    # Використовує бібліотеку Faker
    # @return [Item] новий об'єкт з фіктивними даними
    def self.generate_fake
      title = Faker::Book.title
      category = BOOK_CATEGORIES.sample
      slug = title.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/^_|_$/, "")

      new(
        title: title,
        price: Faker::Commerce.price(range: 10.0..60.0).round(2),
        rating: rand(1..5),
        availability: ["In stock", "Out of stock", "Low stock"].sample,
        category: category,
        url: "http://books.toscrape.com/catalogue/#{slug}/index.html",
        image_path: "products/#{category.downcase.gsub(' ', '_')}/#{slug}.jpg",
        description: Faker::Lorem.paragraph(sentence_count: 3)
      )
    end

    # Метод для конвертації ціни з рядка (£51.77) в число
    # @param price_string [String] рядок з ціною
    # @return [Float] числове значення ціни
    def self.parse_price(price_string)
      price_string.to_s.gsub(/[£$€]/, "").strip.to_f
    end

    # Метод для конвертації рейтингу з класу CSS в число
    # @param rating_class [String] клас CSS (One, Two, Three, Four, Five)
    # @return [Integer] числове значення рейтингу (1-5)
    def self.parse_rating(rating_class)
      rating_map = {
        "One" => 1,
        "Two" => 2,
        "Three" => 3,
        "Four" => 4,
        "Five" => 5
      }
      rating_map[rating_class] || 0
    end

    private

    # Приватний метод для логування ініціалізації об'єкта
    def log_initialization
      LoggerManager.log_info("Створено Item: #{@title} (#{@category}) - £#{@price}")
    rescue StandardError => e
      # Якщо LoggerManager ще не ініціалізований, виводимо в консоль
      puts "[INIT] Створено Item: #{@title}"
    end
  end
end
