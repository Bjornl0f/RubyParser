# Ruby Web Parser

Проект для парсингу веб-сайтів на Ruby.

## Опис проекту

Цей проект призначений для збору даних з веб-сайтів за допомогою бібліотек Ruby.

## Обрані бібліотеки для парсингу

1. **Nokogiri** (~> 1.15) - потужна бібліотека для парсингу HTML/XML документів
2. **HTTParty** (~> 0.21) - зручний HTTP-клієнт для виконання запитів до веб-сторінок
3. **Mechanize** (~> 2.9) - бібліотека для автоматизації взаємодії з веб-сайтами (навігація, заповнення форм)

## Структура проекту

```
RubyParser/
│
├── lib/                         # Папка для бібліотек та основного коду
│   ├── main.rb                  # Головний файл програми
│   ├── my_application_kostyk.rb # Модуль простору імен
│   ├── app_config_loader.rb     # Клас для завантаження конфігурацій
│   ├── logger_manager.rb        # Клас для управління логуванням
│   ├── configurator.rb          # Клас Configurator для налаштувань
│   ├── simple_website_parser.rb # Клас для парсингу сайту
│   ├── database_connector.rb    # Клас для підключення до БД
│   ├── engine.rb                # Клас Engine для управління програмою
│   ├── archive_sender_worker.rb # Sidekiq worker для відправки архівів
│   ├── item.rb                  # Клас Item для представлення книги
│   ├── item_collection.rb       # Клас ItemCollection для колекції книг
│   ├── item_container.rb        # Модуль ItemContainer
│   ├── another_file.rb          # Інший файл з кодом
│   └── tasks/                   # Папка для Rake-задач
│       ├── task1.rake           # Задача для парсингу
│       └── task2.rake           # Задача для експорту даних
│
├── media_dir/                   # Папка для збережених зображень
│   ├── poetry/                  # Зображення книг категорії Poetry
│   ├── fiction/                 # Зображення книг категорії Fiction
│   └── .../                     # Інші категорії
│
├── config/                      # Папка для налаштувань
│   ├── default_config.yaml      # Основний конфігураційний файл
│   ├── web_parser.yaml          # Налаштування веб-скрапінгу
│   ├── logging_config.yaml      # Налаштування логування
│   ├── database_config.yaml     # Налаштування бази даних SQLite
│   ├── application.yml          # Додаткові налаштування
│   └── other_config.yml         # Інші файли налаштувань
│
├── products/                    # Каталог для збереження книг
│   ├── travel/                  # Категорія: Подорожі
│   ├── mystery/                 # Категорія: Детективи
│   ├── historical_fiction/      # Категорія: Історична фантастика
│   ├── romance/                 # Категорія: Романтика
│   └── science_fiction/         # Категорія: Наукова фантастика
│
├── db/                          # Папка для бази даних SQLite
│
├── logs/                        # Папка для логів
│   └── application.log          # Файл для запису логів
│
├── output/                      # Папка для вихідних файлів
│   ├── data.csv                 # Вихідний файл у форматі CSV
│   └── data.json                # Вихідний файл у форматі JSON
│
├── Rakefile                     # Файл для налаштування Rake-задач
├── Gemfile                      # Файл для управління залежностями
├── .rubocop.yml                 # Файл конфігурації для RuboCop
└── README.md                    # Документація проекту
```

## Планування парсингу

### Етап 1: Підготовча робота (ВИКОНАНО)
- [x] Встановлення необхідних бібліотек (nokogiri, httparty, mechanize)
- [x] Створення структури проекту
- [x] Налаштування середовища
- [x] Ініціалізація git репозиторію

### Етап 2: Налаштування системи (ВИКОНАНО)
- [x] Вибір сайту для парсингу (Books to Scrape)
- [x] Визначення даних для збору (title, price, rating, availability, url, category)
- [x] Створення модуля MyApplicationKostyk
- [x] Створення YAML конфігураційних файлів
- [x] Створення каталогу products з категоріями книг
- [x] Створення класу AppConfigLoader
- [x] Реалізація методу load_libs для автопідключення бібліотек
- [x] Створення класу LoggerManager для логування
- [x] Перевірка функціоналу в main.rb

### Етап 3: Реалізація основних класів (ВИКОНАНО)
- [x] Клас Item для представлення книги (8 атрибутів)
- [x] Метод update для зміни через блок
- [x] Alias info для to_s
- [x] Метод generate_fake з Faker
- [x] Модуль Comparable (порівняння за ціною)
- [x] Модуль ItemContainer (ClassMethods, InstanceMethods)
- [x] Клас ItemCollection для колекції книг
- [x] Збереження у форматах: TXT, JSON, CSV, YAML
- [x] Метод generate_test_items для генерації тестових даних
- [x] Модуль Enumerable (map, select, find, reduce, тощо)
- [x] Методи статистики (total_price, average_price, average_rating)
- [x] Клас Configurator для налаштування параметрів
- [x] Клас SimpleWebsiteParser для парсингу сайту

### Етап 4: Розробка парсера (ВИКОНАНО)
- [x] Реалізація логіки парсингу (SimpleWebsiteParser)
- [x] Обробка пагінації
- [x] Збереження зображень в media_dir
- [x] Багатопоточність (concurrent-ruby)

### Етап 5: Підключення до БД (ВИКОНАНО)
- [x] Клас DatabaseConnector для SQLite та MongoDB
- [x] Методи підключення та закриття з'єднання
- [x] Збереження та отримання книг з БД
- [x] Створення таблиць за схемою

### Етап 6: Клас Engine (ВИКОНАНО)
- [x] Клас Engine для управління виконанням програми
- [x] Методи run_website_parser, run_save_to_csv, run_save_to_json, run_save_to_yaml
- [x] Методи run_save_to_sqlite, run_save_to_mongodb
- [x] Архівація вихідних файлів у ZIP
- [x] Клас ArchiveSenderWorker для Sidekiq
- [x] Відправка архіву по email через Pony

### Етап 7: Запуск додатку (ВИКОНАНО)
- [x] Клас Main як точка входу
- [x] Підтримка аргументів командного рядка
- [x] Rake задачі: parser:run, parser:test, parser:pages
- [x] Rake задачі: data:export_csv, data:export_json, data:stats
- [x] Rake задачі: data:clean, data:clean_all
- [x] Обробка помилок та логування

### Етап 8: Документація (ПЛАНУЄТЬСЯ)
- [ ] Документація API
- [ ] Приклади використання

## Сайт для парсингу

**Обраний сайт:** [Books to Scrape](http://books.toscrape.com/)

Це спеціально створений тестовий сайт для практики веб-скрапінгу. Сайт імітує онлайн-магазин книг і повністю дозволяє парсинг (створений саме для цієї мети).

### Дані для збору:

| Поле | Опис | CSS-селектор |
|------|------|--------------|
| `title` | Назва книги | `h3 a[title]` |
| `price` | Ціна книги (£) | `.price_color` |
| `rating` | Рейтинг (1-5 зірок) | `.star-rating` |
| `availability` | Наявність на складі | `.availability` |
| `url` | Посилання на сторінку книги | `h3 a[href]` |
| `category` | Категорія книги | sidebar categories |

### План переходу між сторінками:

1. **Головна сторінка** (`/`) - список всіх книг з пагінацією
2. **Пагінація** - перехід по сторінках через `page-X.html` (всього ~50 сторінок)
3. **Категорії** - навігація по категоріям через бічне меню (`/catalogue/category/books/...`)
4. **Сторінка книги** - детальна інформація про книгу (`/catalogue/book-name_id/index.html`)

### Структура URL:
- Головна: `http://books.toscrape.com/`
- Сторінка пагінації: `http://books.toscrape.com/catalogue/page-2.html`
- Категорія: `http://books.toscrape.com/catalogue/category/books/mystery_3/index.html`
- Книга: `http://books.toscrape.com/catalogue/a-light-in-the-attic_1000/index.html`

## Встановлення

```bash
# Клонування репозиторію
git clone <url-репозиторію>

# Перехід до директорії проекту
cd RubyParser

# Встановлення залежностей
bundle install
```

## Використання

### Командний рядок

```bash
# Запуск з параметрами за замовчуванням
bundle exec ruby lib/main.rb

# Тестовий режим (1 сторінка, без БД)
bundle exec ruby lib/main.rb --test

# Вказати кількість сторінок
bundle exec ruby lib/main.rb --pages=5

# Без багатопоточності
bundle exec ruby lib/main.rb --no-threads

# Тільки CSV експорт
bundle exec ruby lib/main.rb --csv-only

# Без збереження в БД
bundle exec ruby lib/main.rb --no-db

# Довідка
bundle exec ruby lib/main.rb --help
```

### Rake задачі

```bash
# Показати всі доступні задачі
rake help

# Парсинг
rake parser:run          # Повний парсинг (2 сторінки)
rake parser:test         # Тестовий парсинг (1 сторінка)
rake parser:pages[5]     # Парсинг 5 сторінок
rake parser:sequential   # Без багатопоточності

# Експорт даних
rake data:export_csv     # Тільки CSV
rake data:export_json    # Тільки JSON
rake data:export_files   # Без БД
rake data:stats          # Статистика

# Очищення
rake data:clean          # Очистити output
rake data:clean_media    # Очистити зображення
rake data:clean_db       # Очистити SQLite
rake data:clean_all      # Очистити все
```

## Основні класи

### Item
Клас для представлення книги з сайту [Books to Scrape](http://books.toscrape.com/).
Реалізує модуль `Comparable` для порівняння книг за ціною.

**Атрибути (8):**
- `title` - назва книги
- `price` - ціна (Float)
- `rating` - рейтинг 1-5 (Integer)
- `availability` - наявність
- `category` - категорія
- `url` - посилання на сторінку
- `image_path` - шлях до зображення
- `description` - опис книги

**Методи:**
- `initialize(attributes, &block)` - конструктор з підтримкою блоку
- `update(&block)` - зміна атрибутів через блок
- `to_s` / `info` - рядкове представлення (info - alias)
- `to_h` - хеш атрибутів
- `inspect` - інформація про об'єкт
- `<=>` - порівняння книг за ціною (Comparable)
- `Item.generate_fake` - генерація книги з Faker
- `Item.parse_price(string)` - парсинг ціни
- `Item.parse_rating(class)` - парсинг рейтингу

**Приклади:**
```ruby
# Створення з блоком
book = MyApplicationKostyk::Item.new(title: "Sharp Objects", price: 47.82) do |item|
  item.category = "Mystery"
  item.rating = 4
end

# Оновлення через блок
book.update do |item|
  item.price = 50.00
end

# Генерація фіктивних даних
fake_book = MyApplicationKostyk::Item.generate_fake

# Порівняння та сортування
books.sort  # сортує за ціною
book1 < book2  # порівнює за ціною
```

### ItemCollection
Клас для управління колекцією книг. Використовує модулі `ItemContainer` та `Enumerable`.

**Генерація тестових даних:**
- `generate_test_items(count)` - генерує фіктивні книги

**Enumerable методи:**
- `map`, `select`, `reject`, `find`, `reduce`
- `all?`, `any?`, `none?`, `count`, `sort`, `uniq`
- `sort_by_attribute(attribute)` - сортування за атрибутом

**Статистика:**
- `total_price` - загальна вартість
- `average_price` - середня ціна
- `average_rating` - середній рейтинг
- `categories_stats` - статистика по категоріях

**Методи збереження:**
- `save_to_file(path)` - TXT
- `save_to_json(path)` - JSON
- `save_to_csv(path)` - CSV
- `save_to_yml(directory)` - YAML (кожна книга окремо)

**Приклад:**
```ruby
collection = MyApplicationKostyk::ItemCollection.new
collection.generate_test_items(10)

# Enumerable
expensive = collection.select { |book| book.price > 30 }
total = collection.reduce(0) { |sum, book| sum + book.price }

# Статистика
puts collection.average_price
puts collection.categories_stats

# Збереження
collection.save_to_json("output/books.json")
```

### ItemContainer (модуль)
Модуль для розширення функціональності колекцій.

**ClassMethods:**
- `class_info` - інформація про клас
- `instances_count` - кількість створених об'єктів

**InstanceMethods:**
- `add_item`, `remove_item`, `delete_items`
- `method_missing` для `show_all_items`

### SimpleWebsiteParser
Клас для парсингу сайту [Books to Scrape](http://books.toscrape.com/).

**Атрибути:**
- `config` - конфігурація з YAML
- `agent` - Mechanize агент
- `item_collection` - колекція зібраних книг

**Методи:**
- `start_parse(max_pages:, use_threads:)` - запуск парсингу
- `extract_products_links(page)` - витяг посилань на книги
- `parse_product_page(url)` - парсинг сторінки книги
- `save_product_image(url, title, category)` - збереження зображення
- `check_url_response(url)` - перевірка доступності URL
- `stats` - статистика парсингу

**Приклад:**
```ruby
parser = MyApplicationKostyk::SimpleWebsiteParser.new(config)
parser.start_parse(max_pages: 2, use_threads: true)

puts parser.stats[:total_books]
parser.item_collection.save_to_json("output/books.json")
```

### Configurator
Клас для управління конфігураційними параметрами парсингу.

**Параметри:**
- `run_website_parser` - запуск парсингу (0/1)
- `run_save_to_csv` - збереження в CSV (0/1)
- `run_save_to_json` - збереження в JSON (0/1)
- `run_save_to_yaml` - збереження в YAML (0/1)
- `run_save_to_sqlite` - збереження в SQLite (0/1)
- `parser_max_pages` - максимум сторінок (0 = без обмежень)

**Методи:**
- `configure(overrides)` - налаштування параметрів
- `enabled?(key)` - перевірка чи увімкнено
- `get(key)` / `set(key, value)` - отримання/встановлення
- `reset!` - скидання до значень за замовчуванням
- `Configurator.available_methods` - список доступних ключів

**Приклад:**
```ruby
configurator = MyApplicationKostyk::Configurator.new
configurator.configure(
  run_website_parser: 1,
  run_save_to_csv: 1,
  parser_max_pages: 5
)

if configurator.enabled?(:run_website_parser)
  # запуск парсингу
end
```

### DatabaseConnector
Клас для підключення до баз даних SQLite та MongoDB.

**Атрибути:**
- `db` - активне з'єднання з базою даних
- `db_type` - тип бази даних (sqlite/mongodb)
- `config` - конфігурація з YAML

**Методи:**
- `connect_to_database` - підключення до БД на основі типу
- `close_connection` - закриття з'єднання
- `connected?` - перевірка стану з'єднання
- `create_tables` - створення таблиць (SQLite)
- `save_item(item)` - збереження книги в БД
- `save_items(collection)` - збереження колекції книг
- `get_all_items` - отримання всіх книг з БД

**Приклад:**
```ruby
# Підключення до SQLite
db = MyApplicationKostyk::DatabaseConnector.new(config)
db.connect_to_database
db.create_tables

# Збереження книг
db.save_items(collection)

# Отримання книг
items = db.get_all_items

# Закриття з'єднання
db.close_connection
```

### Engine
Головний клас для управління виконанням програми. Координує всі операції: завантаження конфігурації, парсинг, збереження даних.

**Атрибути:**
- `config` - конфігурація з YAML-файлів
- `config_loader` - завантажувач конфігурацій
- `configurator` - конфігуратор параметрів
- `parser` - парсер веб-сайту
- `db_connector` - з'єднання з БД
- `item_collection` - колекція книг

**Методи:**
- `load_config` - завантаження конфігурації з YAML
- `run(config_params)` - головний метод запуску
- `run_methods(config_params)` - виконання методів за конфігурацією
- `run_website_parser` - запуск парсингу сайту
- `run_save_to_csv` - збереження у CSV
- `run_save_to_json` - збереження у JSON
- `run_save_to_yaml` - збереження у YAML
- `run_save_to_sqlite` - збереження у SQLite
- `run_save_to_mongodb` - збереження у MongoDB
- `archive_output_files` - архівація файлів у ZIP

**Приклад:**
```ruby
engine = MyApplicationKostyk::Engine.new
engine.run(
  run_website_parser: 1,
  run_save_to_csv: 1,
  run_save_to_json: 1,
  run_save_to_sqlite: 1,
  parser_max_pages: 5
)
```

### ArchiveSenderWorker
Sidekiq worker для фонової відправки архівів по email.

**Приклад:**
```ruby
# Запуск фонового завдання
ArchiveSenderWorker.perform_async(archive_path, "email@example.com")
```

**Налаштування SMTP (через ENV):**
- `SMTP_ADDRESS` - адреса SMTP сервера
- `SMTP_PORT` - порт SMTP
- `SMTP_USER` - ім'я користувача
- `SMTP_PASSWORD` - пароль
- `SMTP_FROM` - email відправника

## Історія змін

Детальна історія змін доступна у файлі [CHANGELOG.md](CHANGELOG.md).

**Поточна версія: 1.0.0**

Останні зміни:
- Клас `Main` як точка входу для додатку
- Підтримка аргументів командного рядка (--test, --pages, --help)
- Rake задачі для парсингу: parser:run, parser:test, parser:pages
- Rake задачі для даних: data:export_csv, data:export_json, data:stats
- Rake задачі для очищення: data:clean, data:clean_all
- Централізована обробка помилок

## Автор

Стефан Костик

## Ліцензія

MIT License

