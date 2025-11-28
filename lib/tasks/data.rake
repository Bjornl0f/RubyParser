# frozen_string_literal: true

# ============================================
# Rake задачі для роботи з даними
# ============================================

namespace :data do
  desc "Експортувати дані тільки у CSV"
  task :export_csv do
    puts "Експорт у CSV..."
    ruby_cmd = "bundle exec ruby lib/main.rb --csv-only"
    system(ruby_cmd)
  end

  desc "Експортувати дані тільки у JSON"
  task :export_json do
    puts "Експорт у JSON..."
    ruby_cmd = "bundle exec ruby lib/main.rb --json-only"
    system(ruby_cmd)
  end

  desc "Експортувати дані без збереження в БД"
  task :export_files do
    puts "Експорт у файли (без БД)..."
    ruby_cmd = "bundle exec ruby lib/main.rb --no-db"
    system(ruby_cmd)
  end

  desc "Очистити директорію output"
  task :clean do
    require "fileutils"
    output_dir = File.join(Dir.pwd, "output")
    
    if Dir.exist?(output_dir)
      Dir.glob("#{output_dir}/*").each do |file|
        FileUtils.rm_rf(file)
        puts "Видалено: #{file}"
      end
      puts "✓ Директорія output очищена"
    else
      puts "Директорія output не існує"
    end
  end

  desc "Очистити директорію media_dir"
  task :clean_media do
    require "fileutils"
    media_dir = File.join(Dir.pwd, "media_dir")
    
    if Dir.exist?(media_dir)
      Dir.glob("#{media_dir}/*").each do |file|
        FileUtils.rm_rf(file)
        puts "Видалено: #{file}"
      end
      puts "✓ Директорія media_dir очищена"
    else
      puts "Директорія media_dir не існує"
    end
  end

  desc "Очистити базу даних SQLite"
  task :clean_db do
    require "fileutils"
    db_file = File.join(Dir.pwd, "db", "books_parser.sqlite3")
    
    if File.exist?(db_file)
      FileUtils.rm(db_file)
      puts "✓ База даних SQLite видалена"
    else
      puts "База даних SQLite не існує"
    end
  end

  desc "Очистити всі дані (output, media, db)"
  task clean_all: %i[clean clean_media clean_db] do
    puts "\n✓ Всі дані очищено"
  end

  desc "Показати статистику зібраних даних"
  task :stats do
    require "json"
    
    output_dir = File.join(Dir.pwd, "output")
    json_file = File.join(output_dir, "books_export.json")
    
    if File.exist?(json_file)
      data = JSON.parse(File.read(json_file))
      
      puts "\n" + "=" * 50
      puts "СТАТИСТИКА ЗІБРАНИХ ДАНИХ"
      puts "=" * 50
      
      if data["metadata"]
        puts "Всього книг: #{data['metadata']['total_items']}"
        puts "Загальна вартість: £#{data['metadata']['total_price']}"
        puts "Середня ціна: £#{data['metadata']['average_price']}"
        puts "Середній рейтинг: #{data['metadata']['average_rating']}/5"
        puts "Дата експорту: #{data['metadata']['exported_at']}"
      end
      
      if data["items"]
        categories = data["items"].group_by { |item| item["category"] }
        puts "\nКатегорії (#{categories.size}):"
        categories.each do |category, items|
          puts "  #{category}: #{items.size} книг"
        end
      end
      
      puts "=" * 50
    else
      puts "Файл #{json_file} не знайдено. Спочатку запустіть парсинг."
    end
  end
end

