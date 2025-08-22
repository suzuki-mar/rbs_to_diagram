# frozen_string_literal: true

module Formatter
  class Diagram::PlantUML::EntityBuilder
    class EmptyNamespaceEntities
      def self.build(namespace_collection, syntax, indentation)
        entities = [] # : Array[untyped]

        empty_namespaces = namespace_collection.empty_namespaces
        empty_namespaces.each do |ns|
          flattened_name = ns.name.gsub('::', '_')

          entities << Formatter::Diagram::PlantUML::Entity::EmptyNamespace.new(
            name: flattened_name,
            original_name: ns.name,
            syntax: syntax,
            indentation: indentation
          )
        end

        entities
      end
    end
  end
end
