# frozen_string_literal: true

module Formatter
  class Diagram::MermaidJS
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
      end
    end
  end
end
