# frozen_string_literal: true

# ============================================
# Ruby Web Parser - Rakefile
# Головний файл для налаштування Rake-задач
# ============================================

require "rake"

# Завантаження всіх Rake-задач з папки lib/tasks
Dir.glob("lib/tasks/*.rake").each { |task| load task }

# Задача за замовчуванням - запуск парсингу
task default: ["parser:run"]

desc "Показати всі доступні задачі"
task :help do
  puts "\n" + "=" * 60
  puts "RUBY WEB PARSER - ДОСТУПНІ RAKE ЗАДАЧІ"
  puts "=" * 60
  puts ""
  puts "Парсинг:"
  puts "  rake parser:run          - Повний парсинг (2 сторінки)"
  puts "  rake parser:test         - Тестовий парсинг (1 сторінка)"
  puts "  rake parser:pages[N]     - Парсинг N сторінок"
  puts "  rake parser:sequential   - Парсинг без багатопоточності"
  puts "  rake parser:help         - Довідка по параметрах"
  puts ""
  puts "Дані:"
  puts "  rake data:export_csv     - Експорт тільки у CSV"
  puts "  rake data:export_json    - Експорт тільки у JSON"
  puts "  rake data:export_files   - Експорт без БД"
  puts "  rake data:stats          - Статистика зібраних даних"
  puts ""
  puts "Очищення:"
  puts "  rake data:clean          - Очистити output"
  puts "  rake data:clean_media    - Очистити media_dir"
  puts "  rake data:clean_db       - Очистити SQLite БД"
  puts "  rake data:clean_all      - Очистити все"
  puts ""
  puts "=" * 60
end
