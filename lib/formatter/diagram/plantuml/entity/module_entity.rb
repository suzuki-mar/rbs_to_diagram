# frozen_string_literal: true

require_relative 'base'
require_relative '../../indentation'

module Formatter
  class Diagram::PlantUML
    module Entity
      class ModuleEntity < Base
        private attr_reader :methods, :indent, :syntax, :indentation

        def initialize(name:, methods:, syntax:, indentation:, indent: true)
          super(name: name, type: :module, syntax: syntax, indentation: indentation)
          @methods = methods
          @indent = indent
        end

        def render
          indent_str = indentation.to_s
          lines = [] # : Array[String]
          lines << "#{indent_str}class #{name} {"
          lines << "#{indent_str}    <<module>>"
          lines.concat(methods.map(&:to_s))
          lines << "#{indent_str}}"
          lines
        end
      end
    end
  end
end
