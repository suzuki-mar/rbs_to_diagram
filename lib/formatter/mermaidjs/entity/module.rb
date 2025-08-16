# frozen_string_literal: true

require_relative '../syntax'

class Formatter
  class MermaidJS
    module Entity
      # モジュールエンティティ
      class Module < Base
        attr_reader :methods

        def initialize(name:, methods:)
          super(name: name, type: :module)
          @methods = methods
        end

        def render
          Syntax.module_definition(name, methods)
        end

        def render_with_context(has_namespaces:)
          diagrams = has_namespaces ? [''] + render : render
          { diagrams: diagrams, notes: [] }
        end
      end
    end
  end
end
