# frozen_string_literal: true

# Головний модуль додатку для парсингу веб-сайтів
# Автор: Стефан Костик
module MyApplicationKostyk
  VERSION = "0.11.0"

  # Базовий шлях до проекту
  def self.root
    File.expand_path("..", __dir__)
  end

  # Шлях до конфігураційних файлів
  def self.config_path
    File.join(root, "config")
  end

  # Шлях до логів
  def self.logs_path
    File.join(root, "logs")
  end

  # Шлях до вихідних даних
  def self.output_path
    File.join(root, "output")
  end

  # Шлях до каталогу продуктів (книг)
  def self.products_path
    File.join(root, "products")
  end
end

