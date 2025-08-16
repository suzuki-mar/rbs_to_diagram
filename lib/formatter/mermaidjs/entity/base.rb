# frozen_string_literal: true

class Formatter
  class MermaidJS
    module Entity
      # ベースエンティティクラス
      class Base
        attr_reader :name, :type

        def initialize(name:, type:)
          @name = name
          @type = type
        end

        def render
          raise NotImplementedError, 'Subclasses must implement render method'
        end

        def render_with_context(has_namespaces:) # rubocop:disable Lint/UnusedMethodArgument
          { diagrams: render, notes: [] }
        end
      end
    end
  end
end
