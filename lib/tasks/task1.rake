# frozen_string_literal: true

# Перша Rake-задача для парсингу

namespace :parser do
  desc "Запустити основний парсинг"
  task :run do
    puts "Запуск парсингу..."
    require_relative "../main"
  end
end

