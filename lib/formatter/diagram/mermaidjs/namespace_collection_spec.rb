# frozen_string_literal: true

module Formatter
  class Diagram
    class MermaidJS
      class NamespaceCollectionSpec
        def namespace_nodes(parser_result)
          parser_result.find_nodes.select { |n| n.type == :module && n.is_namespace }
        end

        def pick_namespace_for_class(class_node, namespace_nodes)
          c_name = class_node.name
          candidates = namespace_nodes.select { |ns| c_name.start_with?("#{ns.name}::") }
          candidates.max_by { |ns| ns.name.length } # 最深優先
        end

        def empty_namespaces(_parser_result, namespace_nodes, namespaces_with_classes)
          # 子ネームスペースがある親は「空」とみなさないポリシー
          namespace_nodes.reject do |ns|
            namespaces_with_classes.key?(ns.name) ||
              namespace_nodes.any? { |other| other.name != ns.name && other.name.start_with?("#{ns.name}::") }
          end
        end

        def regular_nodes(parser_result)
          parser_result.find_nodes.reject do |node|
            (node.type == :module && node.is_namespace) ||
              (node.type == :class && node.name.include?('::'))
          end
        end
      end
    end
  end
end
