# frozen_string_literal: true

require_relative 'syntax'
require_relative 'entity'

class Formatter
  class MermaidJS
    # MermaidJSエンティティ（namespace、class、module）を構築するクラス
    class EntityBuilder
      def initialize(parser_result, namespace_collection, method_converter)
        @parser_result = parser_result
        @namespace_collection = namespace_collection
        @method_converter = method_converter
      end

      def build_entities
        entities = [] # : Array[Entity::Base]

        # クラスを含むネームスペースエンティティを構築
        namespace_entities = build_namespace_entities_with_classes
        entities.concat(namespace_entities)

        # 通常のクラス・モジュールエンティティを構築
        regular_entities = build_regular_entities
        entities.concat(regular_entities)

        # 空のネームスペースエンティティを構築
        empty_namespace_entities = build_empty_namespace_entities
        entities.concat(empty_namespace_entities)

        entities
      end

      private

      attr_reader :parser_result, :namespace_collection, :method_converter

      def build_namespace_entities_with_classes
        entities = [] # : Array[Entity::Base]

        # クラスを含むネームスペースを構築
        namespaces_with_classes = namespace_collection.collect_namespaces_with_classes

        namespaces_with_classes.each do |namespace_name, classes|
          flattened_name = namespace_name.gsub('::', '_')

          class_entities = classes.map do |class_node|
            simple_name = class_node.name.split('::').last
            methods = method_converter.call(class_node.methods_ordered_by_visibility_and_type, :class)

            Entity::NamespaceClass.new(name: simple_name, methods: methods)
          end

          entities << Entity::Namespace.new(
            name: flattened_name,
            original_name: namespace_name,
            classes: class_entities
          )
        end

        entities
      end

      def build_empty_namespace_entities
        entities = [] # : Array[Entity::Base]

        # 空のネームスペースを構築
        empty_namespaces = namespace_collection.empty_namespaces
        empty_namespaces.each do |ns|
          flattened_name = ns.name.gsub('::', '_')

          entities << Entity::EmptyNamespace.new(
            name: flattened_name,
            original_name: ns.name
          )
        end

        entities
      end

      def build_regular_entities
        entities = [] # : Array[Entity::Base]

        # ネームスペース以外のノード（通常のクラス・モジュール）
        regular_nodes = namespace_collection.regular_nodes

        # ネームスペースが存在するかチェック
        has_namespaces = namespace_collection.namespaces?

        regular_nodes.each do |node|
          entity = Entity.create_for_node(node, method_converter, has_namespaces: has_namespaces)
          entities << entity
        end

        entities
      end
    end
  end
end
