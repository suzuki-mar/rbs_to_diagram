# frozen_string_literal: true

module Formatter
  class Diagram::PlantUML::EntityBuilder
    class RegularEntities
      class << self
        def build(_parser_result, namespace_collection, syntax, indentation)
          entities = [] # : Array[untyped]

          regular_nodes = namespace_collection.regular_nodes
          has_namespaces = namespace_collection.namespaces?

          regular_nodes.each do |node|
            entity = create_entity_for_node(node, has_namespaces: has_namespaces, syntax: syntax,
                                                  indentation: indentation)
            entities << entity
          end

          entities
        end

        private

        def create_entity_for_node(node, has_namespaces:, syntax:, indentation:)
          methods = syntax.method_signatures(node.methods_ordered_by_visibility_and_type)

          case node.type
          when :class
            Formatter::Diagram::PlantUML::Entity::ClassEntity.new(
              name: node.name,
              methods: methods,
              syntax: syntax,
              indentation: indentation
            )
          when :module
            if has_namespaces
              Formatter::Diagram::PlantUML::Entity::ModuleAsClassEntity.new(
                name: node.name,
                methods: methods,
                syntax: syntax,
                indentation: indentation
              )
            else
              Formatter::Diagram::PlantUML::Entity::ModuleEntity.new(
                name: node.name,
                methods: methods,
                syntax: syntax,
                indentation: indentation
              )
            end
          else
            raise "Unknown node type: #{node.type}"
          end
        end
      end
    end
  end
end
