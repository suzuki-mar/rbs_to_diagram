# frozen_string_literal: true

require_relative 'syntax'

class Formatter
  class MermaidJS
    module Entity
      def self.create_for_node(node, method_converter, has_namespaces: false)
        if node.type == :class
          methods = method_converter.call(node.methods_ordered_by_visibility_and_type, :class)
          Class.new(name: node.name, methods: methods)
        elsif has_namespaces
          # ネームスペースコンテキストでは通常のモジュールをクラスとして表示（staticにしない）
          methods = method_converter.call(node.methods_ordered_by_visibility_and_type, :class)
          ModuleAsClass.new(name: node.name, methods: methods)
        else
          methods = method_converter.call(node.methods_ordered_by_visibility_and_type, :module)
          Module.new(name: node.name, methods: methods)
        end
      end

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

      # 空のネームスペースエンティティ
      class EmptyNamespace < Base
        attr_reader :original_name

        def initialize(name:, original_name:)
          super(name: name, type: :empty_namespace)
          @original_name = original_name
        end

        def render
          Syntax.empty_namespace_definition(name)
        end

        def render_with_context(has_namespaces:)
          diagrams = has_namespaces ? [''] + render : render
          { diagrams: diagrams, notes: [] }
        end
      end

      # クラスエンティティ
      class Class < Base
        attr_reader :methods

        def initialize(name:, methods:)
          super(name: name, type: :class)
          @methods = methods
        end

        def render
          Syntax.class_definition(name, methods)
        end

        def render_with_context(has_namespaces:)
          diagrams = has_namespaces ? [''] + render : render
          { diagrams: diagrams, notes: [] }
        end
      end

      # モジュールエンティティ
      class Module < Base
        attr_reader :methods

        def initialize(name:, methods:)
          super(name: name, type: :module)
          @methods = methods
        end

        def render
          Syntax.module_definition(name, methods)
        end

        def render_with_context(has_namespaces:)
          diagrams = has_namespaces ? [''] + render : render
          { diagrams: diagrams, notes: [] }
        end
      end

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

      # ネームスペース内のクラスエンティティ
      class NamespaceClass < Base
        attr_reader :methods

        def initialize(name:, methods:)
          super(name: name, type: :namespace_class)
          @methods = methods
        end

        def render
          # ネームスペース内では使用されない（Namespaceエンティティが直接レンダリング）
          raise NotImplementedError, 'NamespaceClass should not be rendered directly'
        end
      end
    end
  end
end
