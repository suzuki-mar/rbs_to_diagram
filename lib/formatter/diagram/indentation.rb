# frozen_string_literal: true

module Formatter
  class Diagram
    # インデント状態とルールを管理するクラス
    class Indentation
      private attr_reader :level, :width, :char, :has_namespaces

      def initialize(level: 0, width: 4, char: ' ', has_namespaces: false)
        @level = level
        @width = width
        @char = char
        @has_namespaces = has_namespaces
      end

      def increase
        @level += 1 if has_namespaces
        self
      end

      def decrease
        @level -= 1 if level.positive? && has_namespaces
        self
      end

      def reset
        @level = 0
        self
      end

      def to_s
        char * width * level
      end

      def current_level
        level
      end

      def with_increased_level
        increase
        yield self
        decrease
      end

      def copy
        self.class.new(
          level: level,
          width: width,
          char: char,
          has_namespaces: has_namespaces
        )
      end
    end
  end
end
