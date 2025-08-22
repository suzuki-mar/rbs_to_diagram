# frozen_string_literal: true

require_relative 'base'

module Formatter
  class Diagram::PlantUML
    module Entity
      # ネームスペース内のクラスエンティティ
      class NamespaceClass < Base
        attr_reader :methods
        private attr_reader :syntax, :indentation

        def initialize(name:, methods:, syntax:, indentation:)
          super(name: name, type: :namespace_class, syntax: syntax, indentation: indentation)
          @methods = methods
        end

        def render
          lines = [] # : Array[String]
          lines << "class #{name} {"
          lines.concat(methods.map(&:to_s))
          lines << '}'
          lines
        end
      end
    end
  end
end
