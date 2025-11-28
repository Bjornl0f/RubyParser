# frozen_string_literal: true

require_relative "logger_manager"

module MyApplicationKostyk
  # Модуль ItemContainer для розширення функціональності колекцій книг
  # Містить ClassMethods та InstanceMethods для підмішування
  module ItemContainer
    # Версія модуля
    VERSION = "1.0.0"

    # Callback-метод, що викликається при включенні модуля до класу
    # @param base [Class] клас, до якого підмішується модуль
    def self.included(base)
      # Розширюємо клас методами класу
      base.extend(ClassMethods)
      # Додаємо методи екземпляра
      base.include(InstanceMethods)

      LoggerManager.log_info("Модуль ItemContainer підключено до #{base.name}")
    rescue StandardError
      # Якщо LoggerManager ще не ініціалізований
      nil
    end

    # Методи класу для підмішування
    module ClassMethods
      # Лічильник створених об'єктів
      def instances_count
        @instances_count ||= 0
      end

      # Збільшення лічильника
      def increment_instances_count
        @instances_count ||= 0
        @instances_count += 1
      end

      # Скидання лічильника
      def reset_instances_count
        @instances_count = 0
      end

      # Інформація про клас
      # @return [Hash] хеш з інформацією про клас
      def class_info
        {
          name: name,
          version: ItemContainer::VERSION,
          instances_count: instances_count,
          description: "Колекція книг з сайту Books to Scrape"
        }
      end
    end

    # Методи екземпляра для підмішування
    module InstanceMethods
      # Додає книгу до колекції
      # @param item [Item] об'єкт книги
      # @return [Array] оновлений масив книг
      def add_item(item)
        unless item.is_a?(Item)
          LoggerManager.log_error("Спроба додати не-Item об'єкт до колекції")
          raise ArgumentError, "Очікується об'єкт класу Item"
        end

        @items << item
        LoggerManager.log_info("Додано книгу: #{item.title}")
        @items
      rescue StandardError => e
        raise e if e.is_a?(ArgumentError)

        @items << item
        @items
      end

      # Видаляє книгу з колекції за індексом або об'єктом
      # @param item_or_index [Item, Integer] книга або індекс
      # @return [Item, nil] видалена книга або nil
      def remove_item(item_or_index)
        removed = if item_or_index.is_a?(Integer)
                    @items.delete_at(item_or_index)
                  else
                    @items.delete(item_or_index)
                  end

        if removed
          LoggerManager.log_info("Видалено книгу: #{removed.title}")
        end
        removed
      rescue StandardError
        removed
      end

      # Видаляє всі книги з колекції
      # @return [Array] порожній масив
      def delete_items
        count = @items.size
        @items.clear
        LoggerManager.log_info("Видалено всі книги (#{count} шт.)")
        @items
      rescue StandardError
        @items.clear
      end

      # Обробка невідомих методів
      # Дозволяє виклик show_all_items
      def method_missing(method_name, *args, &block)
        if method_name == :show_all_items
          display_all_items
        else
          super
        end
      end

      # Перевірка чи метод підтримується
      def respond_to_missing?(method_name, include_private = false)
        method_name == :show_all_items || super
      end

      private

      # Виводить всі книги в колекції
      def display_all_items
        puts "=" * 60
        puts "КОЛЕКЦІЯ КНИГ (#{@items.size} шт.)"
        puts "=" * 60

        if @items.empty?
          puts "Колекція порожня"
        else
          @items.each_with_index do |item, index|
            puts "#{index + 1}. #{item.title} - £#{item.price} (#{item.category})"
          end
        end

        puts "=" * 60
        @items
      end
    end
  end
end

