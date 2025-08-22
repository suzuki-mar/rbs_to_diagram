# frozen_string_literal: true

module Formatter
  class Diagram
    class NamespaceCollection
      include Enumerable

      def initialize(parser_result, spec:)
        @parser_result = parser_result
        @spec = spec
        @namespace_nodes = @spec.namespace_nodes(parser_result)
        @all_classes = parser_result.find_nodes.select { |n| n.type == :class }
      end

      def namespaces?
        namespace_nodes.any?
      end

      def collect_namespaces_with_classes
        result = {} # : Hash[String, Array[_Node]]
        all_classes.each do |klass|
          ns = spec.pick_namespace_for_class(klass, namespace_nodes)
          next unless ns

          (result[ns.name] ||= []) << klass
        end
        result
      end

      def empty_namespaces
        map = collect_namespaces_with_classes
        spec.empty_namespaces(parser_result, namespace_nodes, map)
      end

      def regular_nodes
        spec.regular_nodes(parser_result)
      end

      def each(&)
        @namespace_nodes.each(&)
      end

      private

      attr_reader :parser_result, :spec, :namespace_nodes, :all_classes
    end
  end
end
