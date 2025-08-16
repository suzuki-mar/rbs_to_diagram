# frozen_string_literal: true

class Formatter
  class MermaidJS
    module Entity
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
