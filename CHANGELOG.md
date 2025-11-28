# Changelog

Всі зміни в проекті документуються в цьому файлі.

Формат базується на [Keep a Changelog](https://keepachangelog.com/uk/1.0.0/).

## [0.9.0] - 2025-11-28

### Додано
- Клас `SimpleWebsiteParser` для парсингу сайту Books to Scrape
- Атрибути: `config`, `agent`, `item_collection`
- Метод `start_parse(max_pages:, use_threads:)` для запуску парсингу
- Методи витягу даних: `extract_product_name`, `extract_product_price`, `extract_product_rating`, `extract_product_description`, `extract_product_image`, `extract_product_category`
- Метод `save_product_image` для збереження зображень в `media_dir` по категоріях
- Багатопоточність з бібліотекою `concurrent-ruby`
- Метод `check_url_response` для перевірки доступності URL
- Обробка пагінації через `find_next_page`
- Метод `stats` для статистики парсингу
- Бібліотека `concurrent-ruby` до Gemfile

## [0.8.0] - 2025-11-28

### Додано
- Клас `Configurator` для управління конфігураційними параметрами
- Атрибут `config` для зберігання налаштувань у вигляді хешу
- Метод `configure(overrides)` для оновлення параметрів
- Метод `enabled?(key)` для перевірки чи параметр увімкнено
- Методи `get(key)` та `set(key, value)` для роботи з параметрами
- Метод `reset!` для скидання до значень за замовчуванням
- Класовий метод `available_methods` для списку доступних ключів
- Конфігураційні параметри: `run_website_parser`, `run_save_to_csv`, `run_save_to_json`, `run_save_to_yaml`, `run_save_to_sqlite`, `run_save_to_mongodb`, `parser_max_pages`, `parser_delay`, `verbose_mode`

## [0.7.0] - 2025-11-28

### Додано
- Метод `generate_test_items(count)` для генерації тестових книг
- Модуль `Enumerable` до класу `ItemCollection`
- Методи Enumerable: `map`, `select`, `reject`, `find`, `reduce`, `all?`, `any?`, `none?`, `count`, `sort`, `uniq`
- Метод `sort_by_attribute(attribute)` для сортування за атрибутом
- Методи статистики: `total_price`, `average_price`, `average_rating`, `categories_stats`
- Метод `find_by_rating(min_rating)` для пошуку за рейтингом

### Покращено
- Розширене логування всіх операцій в `ItemCollection`
- Метадані при збереженні в JSON (total_price, average_price, average_rating)

## [0.6.0] - 2025-11-28

### Додано
- Модуль `ItemContainer` з `ClassMethods` та `InstanceMethods`
- Клас `ItemCollection` для управління колекцією книг
- Методи збереження: `save_to_file`, `save_to_json`, `save_to_csv`, `save_to_yml`
- Методи пошуку: `find_by_category`, `find_by_price_range`
- Методи завантаження: `load_from_json`, `load_from_csv`
- Реалізовано `method_missing` для `show_all_items`

## [0.5.0] - 2025-11-28

### Додано
- Метод `update(&block)` для зміни атрибутів Item через блок
- Alias `info` для методу `to_s`
- Метод `Item.generate_fake` з бібліотекою Faker
- Модуль `Comparable` для порівняння книг за ціною
- Бібліотека Faker до проекту

## [0.4.0] - 2025-11-28

### Додано
- Метод `load_libs` в `AppConfigLoader` для автопідключення бібліотек
- Клас `LoggerManager` для централізованого логування
- Методи логування: `log_info`, `log_warn`, `log_error`, `log_processed_file`

## [0.3.0] - 2025-11-28

### Додано
- Модуль `MyApplicationKostyk` (простір імен)
- YAML конфігураційні файли:
  - `default_config.yaml` - основні параметри
  - `web_parser.yaml` - налаштування веб-скрапінгу
  - `logging_config.yaml` - налаштування логування
  - `database_config.yaml` - налаштування SQLite
- Каталог `products` з категоріями книг
- Клас `AppConfigLoader` для завантаження конфігурацій

## [0.2.0] - 2025-11-28

### Додано
- Обрано сайт для парсингу: [Books to Scrape](http://books.toscrape.com/)
- Визначено структуру даних для збору
- План навігації по сторінках сайту

## [0.1.0] - 2025-11-28

### Додано
- Ініціалізація проекту
- Бібліотеки: nokogiri, httparty, mechanize
- Базова структура проекту
- Конфігурація RuboCop
- Rake-задачі для автоматизації

