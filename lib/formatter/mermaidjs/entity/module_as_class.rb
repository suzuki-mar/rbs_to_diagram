# frozen_string_literal: true

class Formatter
  class MermaidJS
    module Entity
      # ネームスペースコンテキスト用のモジュールエンティティ（クラスとして表示）
      class ModuleAsClass < Base
        attr_reader :methods

        def initialize(name:, methods:)
          super(name: name, type: :module_as_class)
          @methods = methods
        end

        def render
          [
            "class #{name} {",
            *methods.map { |method| "    #{method}" },
            '}'
          ]
        end

        def render_with_context(has_namespaces:)
          diagrams = has_namespaces ? [''] + render : render
          { diagrams: diagrams, notes: [] }
        end
      end
    end
  end
end
