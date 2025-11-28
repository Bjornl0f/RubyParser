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
│   ├── item.rb                  # Клас Item для представлення книги
│   ├── item_collection.rb       # Клас ItemCollection для колекції книг
│   ├── item_container.rb        # Модуль ItemContainer
│   ├── another_file.rb          # Інший файл з кодом
│   └── tasks/                   # Папка для Rake-задач
│       ├── task1.rake           # Задача для парсингу
│       └── task2.rake           # Задача для експорту даних
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

### Етап 4: Розробка парсера (ПЛАНУЄТЬСЯ)
- [ ] Реалізація логіки парсингу
- [ ] Обробка пагінації

### Етап 5: Збереження даних (ПЛАНУЄТЬСЯ)
- [ ] Експорт у CSV формат
- [ ] Експорт у JSON формат

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

```bash
# Запуск основного парсингу
rake parser:run

# Експорт даних у CSV
rake data:export_csv

# Експорт даних у JSON
rake data:export_json
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

## Історія змін

Детальна історія змін доступна у файлі [CHANGELOG.md](CHANGELOG.md).

**Поточна версія: 0.7.0**

Останні зміни:
- Додано модуль `Enumerable` до `ItemCollection`
- Метод `generate_test_items(count)` для генерації тестових даних
- Методи статистики: `total_price`, `average_price`, `average_rating`
- Повне логування всіх операцій

## Автор

Стефан Костик

## Ліцензія

MIT License

