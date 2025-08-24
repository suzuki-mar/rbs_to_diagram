# frozen_string_literal: true

require_relative 'base'
require_relative '../entity_param'

module Formatter
  class Diagram::PlantUML
    module Entity
      class ClassEntity < Base
        extend Forwardable

        private attr_reader :param

        def_delegators :@param, :methods, :indent, :syntax, :indentation

        def initialize(param)
          super(name: param.name, type: :class, syntax: param.syntax, indentation: param.indentation)
          @param = param
        end

        def render
          indent_str = indentation.to_s
          lines = [] # : Array[String]
          lines << "#{indent_str}class #{name} {"
          lines.concat(methods.map(&:to_s))
          lines << "#{indent_str}}"
          lines
        end
      end
    end
  end
end
