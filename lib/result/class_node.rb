# frozen_string_literal: true

require_relative 'node'

class Result
  # クラスを表すノード
  class ClassNode < Node
    attr_reader :superclass, :includes, :extends

    def initialize(name:, superclass: nil, includes: [], extends: [])
      super(name: name, type: :class)
      @superclass = superclass
      @includes = includes
      @extends = extends
    end

    def methods
      result = [] # : Array[Result::MethodNode]
      @children.each do |child|
        result << child if child.is_a?(MethodNode)
      end
      result
    end
  end
end
