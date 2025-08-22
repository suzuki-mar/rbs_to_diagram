# frozen_string_literal: true

require_relative '../syntax'

module Formatter
  class Diagram::MermaidJS
    module Entity
      # 空ネームスペースエンティティ
      class EmptyNamespace < Base
        attr_reader :original_name

        def initialize(name:, original_name:, syntax:, indentation:)
          super(name: name, type: :namespace, syntax: syntax, indentation: indentation)
          @original_name = original_name
        end

        def render
          syntax.empty_namespace_definition(name)
        end
      end
    end
  end
end
