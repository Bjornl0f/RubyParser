# frozen_string_literal: true

# Головний файл програми для парсингу веб-сайтів
# Тут буде основна логіка парсера

require "nokogiri"
require "httparty"
require "mechanize"

puts "Ruby Web Parser - Головний файл"
puts "Nokogiri версія: #{Nokogiri::VERSION}"
puts "HTTParty версія: #{HTTParty::VERSION}"

