# frozen_string_literal: true

require_relative 'base'
require_relative '../../indentation'

module Formatter
  class Diagram::PlantUML
    module Entity
      # 空のネームスペースエンティティ
      class EmptyNamespace < Base
        attr_reader :original_name
        private attr_reader :syntax, :indentation

        def initialize(name:, original_name:, syntax:, indentation:)
          super(name: name, type: :empty_namespace, syntax: syntax, indentation: indentation)
          @original_name = original_name
        end

        def render
          syntax.empty_namespace_definition(name)
        end
      end
    end
  end
end
