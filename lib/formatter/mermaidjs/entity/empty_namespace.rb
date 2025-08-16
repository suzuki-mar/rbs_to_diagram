# frozen_string_literal: true

require_relative '../syntax'

class Formatter
  class MermaidJS
    module Entity
      # 空のネームスペースエンティティ
      class EmptyNamespace < Base
        attr_reader :original_name

        def initialize(name:, original_name:)
          super(name: name, type: :empty_namespace)
          @original_name = original_name
        end

        def render
          Syntax.empty_namespace_definition(name)
        end

        def render_with_context(has_namespaces:)
          diagrams = has_namespaces ? [''] + render : render
          { diagrams: diagrams, notes: [] }
        end
      end
    end
  end
end
