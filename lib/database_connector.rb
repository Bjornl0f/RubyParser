# frozen_string_literal: true

require "fileutils"
require_relative "logger_manager"
require_relative "my_application_kostyk"

module MyApplicationKostyk
  # Клас DatabaseConnector відповідає за підключення до баз даних
  # Підтримує SQLite та MongoDB
  class DatabaseConnector
    attr_reader :db, :db_type, :config

    # Конструктор класу
    # @param config [Hash] хеш з конфігураційними параметрами з YAML-файлу
    def initialize(config)
      @config = config.dig("database") || {}
      @db_type = @config["type"] || "sqlite"
      @db = nil
      LoggerManager.log_info("[DatabaseConnector] Ініціалізовано з типом бази даних: #{@db_type}")
    rescue StandardError => e
      LoggerManager.log_error("[DatabaseConnector] Помилка ініціалізації", e)
      raise
    end

    # Підключення до бази даних на основі типу з конфігурації
    # @return [Object] з'єднання з базою даних
    def connect_to_database
      LoggerManager.log_info("[DatabaseConnector] Спроба підключення до бази даних типу: #{@db_type}")

      case @db_type.downcase
      when "sqlite"
        connect_to_sqlite
      when "mongodb", "mongo"
        connect_to_mongodb
      else
        error_message = "Непідтримуваний тип бази даних: #{@db_type}"
        LoggerManager.log_error("[DatabaseConnector] #{error_message}")
        raise ArgumentError, error_message
      end

      LoggerManager.log_info("[DatabaseConnector] Успішно підключено до бази даних #{@db_type}")
      @db
    rescue StandardError => e
      LoggerManager.log_error("[DatabaseConnector] Помилка підключення до бази даних", e)
      raise
    end

    # Закриття з'єднання з базою даних
    def close_connection
      return unless @db

      LoggerManager.log_info("[DatabaseConnector] Закриття з'єднання з базою даних...")

      case @db_type.downcase
      when "sqlite"
        @db.close if @db.respond_to?(:close)
      when "mongodb", "mongo"
        @db.client.close if @db.respond_to?(:client) && @db.client.respond_to?(:close)
      end

      @db = nil
      LoggerManager.log_info("[DatabaseConnector] З'єднання з базою даних закрито")
    rescue StandardError => e
      LoggerManager.log_error("[DatabaseConnector] Помилка закриття з'єднання", e)
    end

    # Перевірка стану з'єднання
    # @return [Boolean] true якщо з'єднання активне
    def connected?
      !@db.nil?
    end

    # Створення таблиць для SQLite на основі схеми
    def create_tables
      return unless @db_type.downcase == "sqlite" && @db

      schema = @config.dig("schema") || {}
      
      schema.each do |table_name, table_config|
        create_table_sql = build_create_table_sql(table_config)
        @db.execute(create_table_sql)
        LoggerManager.log_info("[DatabaseConnector] Створено таблицю: #{table_name}")
      end
    rescue StandardError => e
      LoggerManager.log_error("[DatabaseConnector] Помилка створення таблиць", e)
    end

    # Збереження книги в базу даних
    # @param item [Item] об'єкт книги для збереження
    def save_item(item)
      case @db_type.downcase
      when "sqlite"
        save_item_to_sqlite(item)
      when "mongodb", "mongo"
        save_item_to_mongodb(item)
      end
    rescue StandardError => e
      LoggerManager.log_error("[DatabaseConnector] Помилка збереження книги: #{item.title}", e)
    end

    # Збереження колекції книг в базу даних
    # @param items [ItemCollection] колекція книг
    def save_items(items)
      count = 0
      items.each do |item|
        save_item(item)
        count += 1
      end
      LoggerManager.log_info("[DatabaseConnector] Збережено #{count} книг в базу даних")
      count
    rescue StandardError => e
      LoggerManager.log_error("[DatabaseConnector] Помилка збереження колекції книг", e)
      0
    end

    # Отримання всіх книг з бази даних
    # @return [Array] масив хешів з даними книг
    def get_all_items
      case @db_type.downcase
      when "sqlite"
        get_all_items_from_sqlite
      when "mongodb", "mongo"
        get_all_items_from_mongodb
      else
        []
      end
    rescue StandardError => e
      LoggerManager.log_error("[DatabaseConnector] Помилка отримання книг з бази даних", e)
      []
    end

    private

    # Приватний метод для підключення до SQLite
    def connect_to_sqlite
      require "sqlite3"

      sqlite_config = @config["sqlite"] || {}
      db_path = sqlite_config["database_path"] || "db/books_parser.sqlite3"
      
      # Створюємо директорію для бази даних, якщо не існує
      db_dir = File.dirname(db_path)
      FileUtils.mkdir_p(db_dir) unless Dir.exist?(db_dir)

      @db = SQLite3::Database.new(db_path)
      @db.results_as_hash = true
      
      # Встановлюємо timeout
      timeout = sqlite_config["timeout"] || 5000
      @db.busy_timeout = timeout

      LoggerManager.log_info("[DatabaseConnector] SQLite підключено: #{db_path}")
    rescue LoadError => e
      LoggerManager.log_error("[DatabaseConnector] Бібліотека sqlite3 не встановлена. Виконайте: gem install sqlite3", e)
      raise
    rescue SQLite3::Exception => e
      LoggerManager.log_error("[DatabaseConnector] SQLite помилка", e)
      raise
    end

    # Приватний метод для підключення до MongoDB
    def connect_to_mongodb
      require "mongo"

      mongodb_config = @config["mongodb"] || {}
      uri = mongodb_config["uri"] || "mongodb://localhost:27017"
      database_name = mongodb_config["database_name"] || "books_parser"

      client = Mongo::Client.new(uri)
      @db = client.use(database_name)

      LoggerManager.log_info("[DatabaseConnector] MongoDB підключено: #{uri}/#{database_name}")
    rescue LoadError => e
      LoggerManager.log_error("[DatabaseConnector] Бібліотека mongo не встановлена. Виконайте: gem install mongo", e)
      raise
    rescue Mongo::Error => e
      LoggerManager.log_error("[DatabaseConnector] MongoDB помилка", e)
      raise
    end

    # Формує SQL для створення таблиці
    # @param table_config [Hash] конфігурація таблиці
    # @return [String] SQL запит для створення таблиці
    def build_create_table_sql(table_config)
      table_name = table_config["name"]
      columns = table_config["columns"] || []

      column_definitions = columns.map do |col|
        col.map { |name, type| "#{name} #{type}" }.join
      end.join(", ")

      "CREATE TABLE IF NOT EXISTS #{table_name} (#{column_definitions})"
    end

    # Збереження книги в SQLite
    # @param item [Item] об'єкт книги
    def save_item_to_sqlite(item)
      sql = <<-SQL
        INSERT INTO books (title, price, rating, availability, category, url, image_path, description)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      SQL

      @db.execute(sql, [
        item.title,
        item.price,
        item.rating,
        item.availability,
        item.category,
        item.url,
        item.image_path,
        item.description
      ])

      LoggerManager.log_info("[DatabaseConnector] SQLite: збережено книгу '#{item.title}'")
    end

    # Збереження книги в MongoDB
    # @param item [Item] об'єкт книги
    def save_item_to_mongodb(item)
      collection_name = @config.dig("mongodb", "collection_name") || "books"
      collection = @db[collection_name]

      document = {
        title: item.title,
        price: item.price,
        rating: item.rating,
        availability: item.availability,
        category: item.category,
        url: item.url,
        image_path: item.image_path,
        description: item.description,
        created_at: Time.now
      }

      collection.insert_one(document)
      LoggerManager.log_info("[DatabaseConnector] MongoDB: збережено книгу '#{item.title}'")
    end

    # Отримання всіх книг з SQLite
    # @return [Array] масив хешів з даними книг
    def get_all_items_from_sqlite
      sql = "SELECT * FROM books"
      results = @db.execute(sql)
      LoggerManager.log_info("[DatabaseConnector] SQLite: отримано #{results.size} книг")
      results
    end

    # Отримання всіх книг з MongoDB
    # @return [Array] масив хешів з даними книг
    def get_all_items_from_mongodb
      collection_name = @config.dig("mongodb", "collection_name") || "books"
      collection = @db[collection_name]
      results = collection.find.to_a
      LoggerManager.log_info("[DatabaseConnector] MongoDB: отримано #{results.size} книг")
      results
    end
  end
end

