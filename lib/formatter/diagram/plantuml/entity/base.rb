# frozen_string_literal: true

require_relative '../../indentation'

module Formatter
  class Diagram::PlantUML
    module Entity
      # ベースエンティティクラス
      class Base
        attr_reader :name, :type
        private attr_reader :syntax, :indentation

        def initialize(name:, type:, syntax:, indentation:)
          @name = name
          @type = type
          @syntax = syntax
          @indentation = indentation
        end

        def render
          raise NotImplementedError, 'Subclasses must implement this method'
        end
      end
    end
  end
end
