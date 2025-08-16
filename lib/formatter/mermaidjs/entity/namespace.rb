# frozen_string_literal: true

require_relative '../syntax'

class Formatter
  class MermaidJS
    module Entity
      # ネームスペースエンティティ
      class Namespace < Base
        attr_reader :original_name, :classes

        def initialize(name:, original_name:, classes:)
          super(name: name, type: :namespace)
          @original_name = original_name
          @classes = classes
        end

        def render
          class_definitions = classes.flat_map do |class_entity|
            [
              "class #{class_entity.name} {",
              *class_entity.methods.map { |method| "    #{method}" },
              '}'
            ]
          end

          Syntax.namespace_definition(name, class_definitions)
        end

        def render_note
          Syntax.note_for_namespace(name, original_name)
        end

        def render_with_context(has_namespaces:) # rubocop:disable Lint/UnusedMethodArgument
          { diagrams: render, notes: [render_note] }
        end
      end
    end
  end
end
