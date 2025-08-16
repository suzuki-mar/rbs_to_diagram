# frozen_string_literal: true

class Formatter
  class MermaidJS
    # MermaidJS専用のネームスペースコレクションクラス
    class NamespaceCollection
      def initialize(parser_result)
        @parser_result = parser_result
        @namespace_nodes = parser_result.find_nodes.select { |node| node.type == :module && node.is_namespace }
        @all_classes = parser_result.find_nodes.select { |node| node.type == :class }
      end

      def namespaces?
        namespace_nodes.any?
      end

      def collect_namespaces_with_classes
        result = {} # : Hash[String, Array[untyped]]

        all_classes.each do |class_node|
          matching_namespaces = collect_matching_namespace_nodes(class_node)
          next if no_valid_namespace?(matching_namespaces)

          deepest_namespace = matching_namespaces.max_by { |ns| ns.name.length }
          next unless deepest_namespace

          result[deepest_namespace.name] ||= []
          result[deepest_namespace.name] << class_node
        end

        result
      end

      def empty_namespaces
        namespaces_with_classes = collect_namespaces_with_classes

        namespace_nodes.reject do |ns|
          namespaces_with_classes.key?(ns.name) || child_namespaces?(ns.name)
        end
      end

      def child_namespaces?(namespace_name)
        namespace_nodes.any? do |ns|
          ns.name != namespace_name && ns.name.start_with?("#{namespace_name}::")
        end
      end

      def regular_nodes
        parser_result.find_nodes.reject do |node|
          (node.type == :module && node.is_namespace) ||
            (node.type == :class && node.name.include?('::'))
        end
      end

      private

      attr_reader :parser_result, :namespace_nodes, :all_classes

      def collect_matching_namespace_nodes(class_node)
        namespace_nodes.select do |ns|
          class_node.name.start_with?("#{ns.name}::")
        end
      end

      def no_valid_namespace?(matching_namespaces)
        matching_namespaces.empty?
      end
    end
  end
end
