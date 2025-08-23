# frozen_string_literal: true

module Formatter
  class Diagram::PlantUML
    class NamespaceCollectionSpec
      def namespace_nodes(parser_result)
        # 「他ノードに ns::xxx が存在するモジュール」または「is_namespace: true のモジュール」を名前空間と推定
        modules = parser_result.find_nodes.select { |n| n.type == :module }

        names = parser_result.find_nodes.map(&:name)
        select_namespace_modules(modules, names)
      end

      def pick_namespace_for_class(class_node, namespace_nodes)
        parts = class_node.name.split('::')
        return nil if parts.length <= 1

        ns_name = parts[0..-2]&.join('::') # 直近親
        namespace_nodes.find { |ns| ns.name == ns_name }
      end

      def empty_namespaces(_parser_result, namespace_nodes, namespaces_with_classes)
        # 直下クラスがなく、かつ子ネームスペースもなければ「空」とみなす
        namespace_nodes.reject do |ns|
          namespaces_with_classes.key?(ns.name) ||
            namespace_nodes.any? { |other| other.name != ns.name && other.name.start_with?("#{ns.name}::") }
        end
      end

      def regular_nodes(parser_result)
        # 名前に '::' を含むノードと、名前空間として認識されたモジュールは除外
        namespace_nodes_set = namespace_nodes(parser_result).to_set(&:name)
        parser_result.find_nodes.reject do |n|
          n.name.include?('::') ||
            (n.type == :module && namespace_nodes_set.include?(n.name))
        end
      end

      private

      def select_namespace_modules(modules, names)
        # moduleは予約語なのでmという短縮語を使っている
        modules.select do |m|
          names.any? { |name| name != m.name && name.start_with?("#{m.name}::") } ||
            (m.respond_to?(:is_namespace) && m.is_namespace)
        end
      end
    end
  end
end
