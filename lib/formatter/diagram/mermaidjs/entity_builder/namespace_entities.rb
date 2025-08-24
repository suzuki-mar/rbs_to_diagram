# frozen_string_literal: true

module Formatter
  class Diagram::MermaidJS::EntityBuilder
    class NamespaceEntities
      class << self
        def build(namespace_collection, syntax)
          entities = [] # : Array[Formatter::Diagram::MermaidJS::Entity::Namespace]

          namespace_collection.collect_namespaces_with_classes.each do |namespace_name, classes|
            flattened_name = namespace_name.gsub('::', '_')

            class_entities = build_class_entities(classes, syntax)

            indentation = ::Formatter::Diagram::Indentation.new(level: 0)
            entities << Formatter::Diagram::MermaidJS::Entity::Namespace.new(
              name: flattened_name,
              original_name: namespace_name,
              classes: class_entities,
              syntax: syntax,
              indentation: indentation
            )
          end

          entities
        end

        private

        def build_class_entities(classes, syntax)
          indentation = ::Formatter::Diagram::Indentation.new(level: 1) # 使い回し
          classes.map do |class_node|
            simple_name = class_node.name.split('::').last
            methods = syntax.method_signatures(class_node.methods_ordered_by_visibility_and_type)

            Formatter::Diagram::MermaidJS::Entity::NamespaceClass.new(
              name: simple_name,
              methods: methods,
              syntax: syntax,
              indentation: indentation
            )
          end
        end
      end
    end
  end
end
