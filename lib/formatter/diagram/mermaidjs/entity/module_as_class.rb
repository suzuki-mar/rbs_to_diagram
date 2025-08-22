# frozen_string_literal: true

require_relative '../syntax'

module Formatter
  class Diagram::MermaidJS
    module Entity
      # モジュールをクラスとして扱うエンティティ
      class ModuleAsClass < Base
        attr_reader :methods
        private attr_reader :indent

        def initialize(name:, methods:, syntax:, indentation:, indent: true)
          super(name: name, type: :module_as_class, syntax: syntax, indentation: indentation)
          @methods = methods
          @indent = indent
        end

        def render
          syntax.class_definition(name, methods)
        end
      end
    end
  end
end
