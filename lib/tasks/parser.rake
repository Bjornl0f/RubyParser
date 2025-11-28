# frozen_string_literal: true

# ============================================
# Rake задачі для парсингу
# ============================================

namespace :parser do
  desc "Запустити повний парсинг сайту Books to Scrape"
  task :run do
    puts "Запуск парсера..."
    ruby_cmd = "bundle exec ruby lib/main.rb"
    system(ruby_cmd)
  end

  desc "Запустити тестовий парсинг (1 сторінка)"
  task :test do
    puts "Запуск тестового парсингу..."
    ruby_cmd = "bundle exec ruby lib/main.rb --test"
    system(ruby_cmd)
  end

  desc "Запустити парсинг з вказаною кількістю сторінок"
  task :pages, [:count] do |_t, args|
    count = args[:count] || 2
    puts "Запуск парсингу (#{count} сторінок)..."
    ruby_cmd = "bundle exec ruby lib/main.rb --pages=#{count}"
    system(ruby_cmd)
  end

  desc "Запустити парсинг без багатопоточності"
  task :sequential do
    puts "Запуск послідовного парсингу..."
    ruby_cmd = "bundle exec ruby lib/main.rb --no-threads"
    system(ruby_cmd)
  end

  desc "Показати довідку"
  task :help do
    ruby_cmd = "bundle exec ruby lib/main.rb --help"
    system(ruby_cmd)
  end
end

