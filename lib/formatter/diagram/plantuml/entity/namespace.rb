# frozen_string_literal: true

require_relative 'base'
require_relative '../../indentation'

module Formatter
  class Diagram::PlantUML
    module Entity
      # ネームスペースエンティティ
      class Namespace < Base
        attr_reader :original_name, :classes
        private attr_reader :syntax, :indentation

        def initialize(name:, original_name:, classes:, syntax:, indentation:)
          super(name: name, type: :namespace, syntax: syntax, indentation: indentation)
          @original_name = original_name
          @classes = classes
        end

        def render
          indent_str = indentation.to_s
          indentation.copy.increase
          content = classes.flat_map(&:render)
          lines = [] # : Array[String]
          lines << "#{indent_str}package #{name} {"
          lines.concat(content)
          lines << "#{indent_str}}"
          lines
        end

        def render_note
          syntax.note_for_namespace(name, original_name)
        end
      end
    end
  end
end
