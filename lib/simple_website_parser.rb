# frozen_string_literal: true

require "mechanize"
require "nokogiri"
require "open-uri"
require "fileutils"
require "concurrent"

require_relative "item"
require_relative "item_collection"
require_relative "logger_manager"

module MyApplicationKostyk
  # Клас SimpleWebsiteParser для парсингу сайту Books to Scrape
  # Використовує Mechanize для навігації та Nokogiri для парсингу HTML
  class SimpleWebsiteParser
    # Атрибути класу
    attr_reader :config, :agent, :item_collection

    # Базовий URL сайту
    BASE_URL = "http://books.toscrape.com"

    # Конструктор класу
    # @param config [Hash] конфігурація з YAML-файлу
    def initialize(config)
      @config = config["web_scraping"] || config
      @agent = Mechanize.new
      @agent.user_agent_alias = "Windows Chrome"
      @item_collection = ItemCollection.new
      @media_dir = File.join(Dir.pwd, "media_dir")
      @parsed_count = 0
      @mutex = Mutex.new

      setup_agent
      LoggerManager.log_info("SimpleWebsiteParser ініціалізовано")
    rescue StandardError => e
      LoggerManager.log_error("Помилка ініціалізації парсера", e)
      raise
    end

    # Налаштування агента Mechanize
    def setup_agent
      @agent.open_timeout = 30
      @agent.read_timeout = 30
      @agent.history.max_size = 1
      @agent.robots = false
    end

    # Головний метод для запуску парсингу
    # @param max_pages [Integer] максимальна кількість сторінок (0 = без обмежень)
    # @param use_threads [Boolean] використовувати багатопоточність
    # @return [ItemCollection] колекція зібраних книг
    def start_parse(max_pages: nil, use_threads: true)
      max_pages ||= @config["max_pages"] || 0
      start_url = @config["start_page"] || "#{BASE_URL}/"

      LoggerManager.log_info("Початок парсингу: #{start_url}")
      LoggerManager.log_info("Максимум сторінок: #{max_pages == 0 ? 'без обмежень' : max_pages}")

      unless check_url_response(start_url)
        LoggerManager.log_error("Стартова сторінка недоступна: #{start_url}")
        return @item_collection
      end

      current_url = start_url
      page_count = 0

      loop do
        page_count += 1
        break if max_pages.positive? && page_count > max_pages

        LoggerManager.log_info("Парсинг сторінки #{page_count}: #{current_url}")

        begin
          page = @agent.get(current_url)
          product_links = extract_products_links(page)

          LoggerManager.log_info("Знайдено #{product_links.size} книг на сторінці #{page_count}")

          if use_threads
            parse_products_threaded(product_links)
          else
            parse_products_sequential(product_links)
          end

          # Пошук наступної сторінки
          next_page = find_next_page(page)
          break unless next_page

          current_url = next_page
          sleep(@config["request_delay"] || 1)
        rescue StandardError => e
          LoggerManager.log_error("Помилка парсингу сторінки #{page_count}", e)
          break
        end
      end

      LoggerManager.log_info("Парсинг завершено. Зібрано #{@item_collection.size} книг")
      @item_collection
    end

    # Витягує посилання на продукти зі сторінки
    # @param page [Mechanize::Page] HTML-сторінка
    # @return [Array<String>] масив посилань на продукти
    def extract_products_links(page)
      selector = @config["product_link_selector"] || "h3 a"
      links = []

      page.search("article.product_pod").each do |product|
        link_element = product.at_css(selector)
        next unless link_element

        href = link_element["href"]
        next unless href

        # Формуємо повний URL
        full_url = if href.start_with?("http")
                     href
                   elsif href.start_with?("catalogue/")
                     "#{BASE_URL}/#{href}"
                   else
                     "#{BASE_URL}/catalogue/#{href}"
                   end

        links << full_url
      end

      links
    end

    # Парсинг продуктів послідовно
    # @param product_links [Array<String>] масив посилань
    def parse_products_sequential(product_links)
      product_links.each do |link|
        parse_product_page(link)
        sleep(@config["request_delay"] || 1)
      end
    end

    # Парсинг продуктів з використанням багатопоточності
    # @param product_links [Array<String>] масив посилань
    def parse_products_threaded(product_links)
      pool = Concurrent::FixedThreadPool.new(5)

      futures = product_links.map do |link|
        Concurrent::Future.execute(executor: pool) do
          parse_product_page(link)
        end
      end

      # Очікуємо завершення всіх потоків
      futures.each(&:wait)
      pool.shutdown
      pool.wait_for_termination
    end

    # Парсинг сторінки окремого продукту
    # @param product_url [String] URL-адреса продукту
    # @return [Item, nil] об'єкт Item або nil при помилці
    def parse_product_page(product_url)
      return nil unless check_url_response(product_url)

      begin
        page = @agent.get(product_url)
        product = page.search(".product_page").first || page

        # Витягуємо дані
        title = extract_product_name(product)
        price = extract_product_price(product)
        rating = extract_product_rating(product)
        availability = extract_product_availability(product)
        description = extract_product_description(page)
        image_url = extract_product_image(product)
        category = extract_product_category(page)

        # Зберігаємо зображення
        image_path = save_product_image(image_url, title, category)

        # Створюємо об'єкт Item
        item = Item.new(
          title: title,
          price: price,
          rating: rating,
          availability: availability,
          category: category,
          url: product_url,
          image_path: image_path,
          description: description
        )

        # Додаємо до колекції (потокобезпечно)
        @mutex.synchronize do
          @item_collection.add_item(item)
          @parsed_count += 1
        end

        LoggerManager.log_processed_file(title, "Спарсено книгу")
        item
      rescue StandardError => e
        LoggerManager.log_error("Помилка парсингу продукту: #{product_url}", e)
        nil
      end
    end

    # Витягує назву продукту
    # @param product [Nokogiri::XML::Element] елемент продукту
    # @return [String] назва продукту
    def extract_product_name(product)
      # Спробуємо знайти в різних місцях
      title_element = product.at_css("h1") || product.at_css(".product_main h1")
      title_element&.text&.strip || "Unknown Title"
    end

    # Витягує ціну продукту
    # @param product [Nokogiri::XML::Element] елемент продукту
    # @return [Float] ціна продукту
    def extract_product_price(product)
      selector = @config["product_price_selector"] || ".price_color"
      price_element = product.at_css(selector)
      return 0.0 unless price_element

      Item.parse_price(price_element.text)
    end

    # Витягує рейтинг продукту
    # @param product [Nokogiri::XML::Element] елемент продукту
    # @return [Integer] рейтинг (1-5)
    def extract_product_rating(product)
      selector = @config["product_rating_selector"] || ".star-rating"
      rating_element = product.at_css(selector)
      return 0 unless rating_element

      # Рейтинг зберігається в класі (One, Two, Three, Four, Five)
      rating_class = rating_element["class"]
      rating_word = rating_class.to_s.split.find { |c| %w[One Two Three Four Five].include?(c) }
      Item.parse_rating(rating_word)
    end

    # Витягує наявність продукту
    # @param product [Nokogiri::XML::Element] елемент продукту
    # @return [String] статус наявності
    def extract_product_availability(product)
      selector = @config["product_availability_selector"] || ".availability"
      availability_element = product.at_css(selector)
      availability_element&.text&.strip&.gsub(/\s+/, " ") || "Unknown"
    end

    # Витягує опис продукту
    # @param page [Mechanize::Page] сторінка продукту
    # @return [String] опис продукту
    def extract_product_description(page)
      # Опис знаходиться після заголовка "Product Description"
      desc_element = page.at_css("#product_description ~ p")
      desc_element&.text&.strip || ""
    end

    # Витягує URL зображення продукту
    # @param product [Nokogiri::XML::Element] елемент продукту
    # @return [String] URL зображення
    def extract_product_image(product)
      selector = @config["product_image_selector"] || ".thumbnail img, .item img, #product_gallery img"
      image_element = product.at_css(selector) || product.at_css("img")
      return "" unless image_element

      src = image_element["src"]
      return "" unless src

      # Формуємо повний URL
      if src.start_with?("http")
        src
      elsif src.start_with?("../../")
        "#{BASE_URL}/#{src.gsub('../../', '')}"
      else
        "#{BASE_URL}/#{src}"
      end
    end

    # Витягує категорію продукту
    # @param page [Mechanize::Page] сторінка продукту
    # @return [String] категорія
    def extract_product_category(page)
      breadcrumb = page.search(".breadcrumb li")
      return "Uncategorized" if breadcrumb.size < 3

      # Категорія зазвичай третій елемент в breadcrumb
      breadcrumb[2]&.text&.strip || "Uncategorized"
    end

    # Зберігає зображення продукту
    # @param image_url [String] URL зображення
    # @param title [String] назва продукту
    # @param category [String] категорія продукту
    # @return [String] шлях до збереженого файлу
    def save_product_image(image_url, title, category)
      return "" if image_url.empty?

      begin
        # Створюємо директорію для категорії
        category_slug = category.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/^_|_$/, "")
        category_dir = File.join(@media_dir, category_slug)
        FileUtils.mkdir_p(category_dir)

        # Генеруємо ім'я файлу
        title_slug = title.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/^_|_$/, "")[0..50]
        extension = File.extname(URI.parse(image_url).path) || ".jpg"
        filename = "#{title_slug}#{extension}"
        filepath = File.join(category_dir, filename)

        # Завантажуємо та зберігаємо зображення
        URI.open(image_url) do |image|
          File.open(filepath, "wb") do |file|
            file.write(image.read)
          end
        end

        LoggerManager.log_info("Збережено зображення: #{filepath}")
        filepath
      rescue StandardError => e
        LoggerManager.log_error("Помилка збереження зображення: #{image_url}", e)
        ""
      end
    end

    # Знаходить посилання на наступну сторінку
    # @param page [Mechanize::Page] поточна сторінка
    # @return [String, nil] URL наступної сторінки або nil
    def find_next_page(page)
      selector = @config["next_page_selector"] || ".pager .next a"
      next_link = page.at_css(selector)
      return nil unless next_link

      href = next_link["href"]
      return nil unless href

      # Формуємо повний URL
      if href.start_with?("http")
        href
      elsif href.start_with?("catalogue/")
        "#{BASE_URL}/#{href}"
      else
        "#{BASE_URL}/catalogue/#{href}"
      end
    end

    # Перевіряє доступність URL
    # @param url [String] URL для перевірки
    # @return [Boolean] true якщо доступний
    def check_url_response(url)
      response = @agent.head(url)
      response.code.to_i == 200
    rescue StandardError => e
      LoggerManager.log_warn("URL недоступний: #{url} - #{e.message}")
      false
    end

    # Отримує статистику парсингу
    # @return [Hash] статистика
    def stats
      {
        total_books: @item_collection.size,
        total_price: @item_collection.total_price.round(2),
        average_price: @item_collection.average_price.round(2),
        categories: @item_collection.categories_stats
      }
    end
  end
end

