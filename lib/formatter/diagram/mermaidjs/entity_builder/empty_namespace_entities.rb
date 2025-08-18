# frozen_string_literal: true

module Formatter
  class Diagram::MermaidJS::EntityBuilder
    class EmptyNamespaceEntities
      def self.build(namespace_collection, syntax)
        entities = [] # : Array[untyped]

        namespace_collection.empty_namespaces.each do |ns|
          flattened_name = ns.name.gsub('::', '.')
          indentation = ::Formatter::Diagram::Indentation.new(level: 1)
          entities << Formatter::Diagram::MermaidJS::Entity::EmptyNamespace.new(
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
