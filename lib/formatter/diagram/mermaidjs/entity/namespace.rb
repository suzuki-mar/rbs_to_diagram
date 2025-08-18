# frozen_string_literal: true

require_relative '../syntax'

module Formatter
  class Diagram::MermaidJS
    module Entity
      # ネームスペースエンティティ
      class Namespace < Base
        attr_reader :original_name, :classes

        def initialize(name:, original_name:, classes:, syntax:, indentation:)
          super(name: name, type: :namespace, syntax: syntax, indentation: indentation)
          @original_name = original_name
          @classes = classes
        end

        def render
          syntax.namespace_definition(name, classes.map(&:render).flatten)
        end

        def render_note
          syntax.note_for_namespace(name, original_name)
        end
      end
    end
  end
end
