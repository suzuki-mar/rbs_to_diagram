# frozen_string_literal: true

module Formatter
  class Diagram::PlantUML::EntityBuilder
    class NamespaceEntities
      def self.build(namespace_collection, syntax, indentation)
        entities = [] # : Array[untyped]

        namespace_collection.collect_namespaces_with_classes.each do |namespace_name, classes|
          flattened_name = namespace_name.gsub('::', '_')

          class_entities = classes.map do |class_node|
            simple_name = class_node.name.split('::').last
            methods = syntax.method_signatures(class_node.methods_ordered_by_visibility_and_type)

            Formatter::Diagram::PlantUML::Entity::NamespaceClass.new(
              name: simple_name,
              methods: methods,
              syntax: syntax,
              indentation: indentation
            )
          end

          entities << Formatter::Diagram::PlantUML::Entity::Namespace.new(
            name: flattened_name,
            original_name: namespace_name,
            classes: class_entities,
            syntax: syntax,
            indentation: indentation
          )
        end

        entities
      end
    end
  end
end
