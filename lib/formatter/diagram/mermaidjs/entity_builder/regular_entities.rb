# frozen_string_literal: true

module Formatter
  class Diagram::MermaidJS::EntityBuilder
    class RegularEntities
      class << self
        def build(parser_result, namespace_collection, syntax)
          entities = [] # : Array[untyped]

          namespace_class_names = namespace_collection.collect_namespaces_with_classes.values.flatten.to_set(&:name)
          namespace_collection.collect_namespaces_with_classes.keys.to_set

          parser_result.each do |node|
            next if entity_excluded_node?(node, namespace_class_names)

            has_namespaces = namespace_collection.any? { |ns| ns.name == node.name }
            entity = create_entity_for_node(node, has_namespaces: has_namespaces, syntax: syntax)
            entities << entity
          end

          entities
        end

        private

        def entity_excluded_node?(node, namespace_class_names)
          namespace_class_names.include?(node.name) ||
            (node.type == :module && node.is_namespace)
        end

        def create_entity_for_node(node, has_namespaces:, syntax:)
          methods = syntax.method_signatures(node.methods_ordered_by_visibility_and_type)

          case node.type
          when :class
            build_class_entity(node, methods, syntax)
          when :module
            build_module_entity(node, methods, syntax, has_namespaces)
          else
            raise "Unknown node type: #{node.type}"
          end
        end

        def build_class_entity(node, methods, syntax)
          indentation = ::Formatter::Diagram::Indentation.new(level: 1)
          Formatter::Diagram::MermaidJS::Entity::Class.new(
            name: node.name,
            methods: methods,
            syntax: syntax,
            indentation: indentation
          )
        end

        def build_module_entity(node, methods, syntax, has_namespaces)
          level = has_namespaces ? 1 : 0
          entity_class = if has_namespaces
                           Formatter::Diagram::MermaidJS::Entity::ModuleAsClass
                         else
                           Formatter::Diagram::MermaidJS::Entity::Module
                         end

          indentation = ::Formatter::Diagram::Indentation.new(level: level)
          entity_class.new(
            name: node.name,
            methods: methods,
            syntax: syntax,
            indentation: indentation
          )
        end
      end
    end
  end
end
