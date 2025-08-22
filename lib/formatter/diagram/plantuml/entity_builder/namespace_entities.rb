# frozen_string_literal: true

module Formatter
  class Diagram::PlantUML::EntityBuilder
    class NamespaceEntities
      def self.build(namespace_collection, syntax, indentation)
        new(namespace_collection, syntax, indentation).build
      end

      private_class_method :new

      def initialize(namespace_collection, syntax, indentation)
        @namespace_collection = namespace_collection
        @syntax = syntax
        @indentation = indentation
      end

      def build
        entities = [] # : Array[untyped]

        namespace_collection.collect_namespaces_with_classes.each do |namespace_name_str, classes|
          namespace_name = NamespaceName.new(namespace_name_str)

          class_entities = build_class_entities(classes)

          innermost_namespace = build_innermost_namespace(class_entities, namespace_name)

          ancestor_names = namespace_name.ancestor_names
          nested_namespace = if ancestor_names.empty?
                               innermost_namespace
                             else
                               build_namespace_hierarchy(innermost_namespace, ancestor_names)
                             end

          entities << nested_namespace
        end

        entities
      end

      private

      attr_reader :namespace_collection, :syntax, :indentation

      class NamespaceName
        attr_reader :value

        def initialize(value)
          @value = value
        end

        # parts[0..-2] 相当（各段階のフルネームをNamespaceNameで返す）
        def ancestor_names
          arr = value.split('::')
          (1...arr.size).map do |i|
            namespace_parts = arr.take(i)
            self.class.new(namespace_parts.join('::'))
          end
        end

        def position_of(part)
          value.split('::').index(part)
        end

        def namespace_path_until(part)
          idx = position_of(part)
          return nil unless idx

          value.split('::')[0..idx]
        end

        def basename
          value.split('::').last
        end

        def to_s
          value
        end
      end

      def build_nested_namespace(namespace_name, classes)
        class_entities = build_class_entities(classes)

        innermost_namespace = build_innermost_namespace(class_entities, namespace_name)

        ancestor_names = namespace_name.ancestor_names
        return innermost_namespace if ancestor_names.empty?

        build_namespace_hierarchy(innermost_namespace, ancestor_names)
      end

      def build_class_entities(classes)
        classes.map do |class_node|
          simple_name = class_node.name.split('::').last
          methods = syntax.method_signatures(class_node.methods_ordered_by_visibility_and_type)

          Formatter::Diagram::PlantUML::Entity::NamespaceClass.new(
            name: simple_name,
            methods: methods,
            syntax: syntax,
            indentation: indentation
          )
        end
      end

      def build_innermost_namespace(class_entities, namespace_name)
        Formatter::Diagram::PlantUML::Entity::Namespace.new(
          name: namespace_name.basename,
          original_name: namespace_name.to_s,
          classes: class_entities,
          syntax: syntax,
          indentation: indentation
        )
      end

      def build_namespace_hierarchy(innermost_namespace, ancestor_names)
        ancestor_names.reverse.reduce(innermost_namespace) do |inner_namespace, namespace_name|
          Formatter::Diagram::PlantUML::Entity::Namespace.new(
            name: namespace_name.basename,
            original_name: namespace_name.to_s,
            classes: [inner_namespace],
            syntax: syntax,
            indentation: indentation
          )
        end
      end
    end
  end
end
