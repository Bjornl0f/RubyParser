# frozen_string_literal: true

# Головний Rakefile для налаштування Rake-задач

require "rake"

# Завантаження всіх Rake-задач з папки lib/tasks
Dir.glob("lib/tasks/*.rake").each { |task| load task }

# Задача за замовчуванням
task default: ["parser:run"]

