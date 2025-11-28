# frozen_string_literal: true

# Друга Rake-задача для обробки даних

namespace :data do
  desc "Експортувати дані у CSV"
  task :export_csv do
    puts "Експорт даних у CSV..."
  end

  desc "Експортувати дані у JSON"
  task :export_json do
    puts "Експорт даних у JSON..."
  end
end

