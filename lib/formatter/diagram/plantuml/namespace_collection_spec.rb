# frozen_string_literal: true

module Formatter
  class Diagram
    class PlantUML
      class NamespaceCollectionSpec
        def namespace_nodes(parser_result)
          # 「他ノードに ns::xxx が存在するモジュール」を名前空間と推定
          modules = parser_result.find_nodes.select { |n| n.type == :module }
          names = parser_result.find_nodes.map(&:name)
          modules.select { |m| names.any? { |nm| nm != m.name && nm.start_with?("#{m.name}::") } }
        end

        def pick_namespace_for_class(class_node, namespace_nodes)
          parts = class_node.name.split('::')
          return nil if parts.length <= 1

          ns_name = parts[0..-2]&.join('::') # 直近親
          namespace_nodes.find { |ns| ns.name == ns_name }
        end

        def empty_namespaces(_parser_result, namespace_nodes, namespaces_with_classes)
          # 直下クラスが無ければ「空」とみなす（子ネームスペースがあっても空）
          namespace_nodes.reject { |ns| namespaces_with_classes.key?(ns.name) }
        end

        def regular_nodes(parser_result)
          # 名前に '::' を含むノードは除外（トップレベルを丸ごと返す）
          parser_result.find_nodes.reject { |n| n.name.include?('::') }
        end
      end
    end
  end
end
