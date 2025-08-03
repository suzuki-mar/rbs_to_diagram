# frozen_string_literal: true

class Result
  # Compositeパターンの基底クラス
  class Node
    attr_reader :name, :type, :children

    def initialize(name:, type:, children: [])
      @name = name
      @type = type
      @children = children.dup
    end

    def add_child(child)
      @children << child
    end

    def find_by_type(target_type)
      result = [] # : Array[Result::Node]
      result << self if @type == target_type
      @children.each { |child| result.concat(child.find_by_type(target_type)) if child.respond_to?(:find_by_type) }
      result
    end
  end
end
