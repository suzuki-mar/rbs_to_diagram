# frozen_string_literal: true

require_relative '../syntax'

module Formatter
  class Diagram::MermaidJS
    module Entity
      # ネームスペース内のクラスエンティティ
      class NamespaceClass < Base
        attr_reader :methods

        def initialize(name:, methods:, syntax:, indentation:)
          super(name: name, type: :class, syntax: syntax, indentation: indentation)
          @methods = methods
        end

        def render
          # namespace内のクラスは特別処理：クラス定義は0スペース、メソッドはmethod_signaturesで既にインデント済み
          lines = [] # : Array[String]
          lines << "class #{name} {"
          methods.each do |m|
            lines << m.to_s
          end
          lines << '}'
          lines
        end
      end
    end
  end
end
