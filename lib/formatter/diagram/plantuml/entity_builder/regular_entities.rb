# frozen_string_literal: true

module Formatter
  class Diagram::PlantUML::EntityBuilder
    class RegularEntities
      class << self
        def build(_parser_result, namespace_collection, syntax, indentation)
          entities = [] # : Array[Formatter::Diagram::PlantUML::Entity::Base]

          regular_nodes = namespace_collection.regular_nodes
          has_namespaces = namespace_collection.namespaces?

          regular_nodes.each do |node|
            entity = create_entity_for_node(node, has_namespaces: has_namespaces, syntax: syntax,
                                                  indentation: indentation)
            entities << entity if entity # nilの場合は追加しない
          end

          entities
        end

        private

        def create_entity_for_node(node, has_namespaces:, syntax:, indentation:)
          case node.type
          when :class
            build_class_entity(node: node, syntax: syntax, indentation: indentation)
          when :inner_class
            # Type cast to _InnerClassNode since we know it's an inner class
            inner_class_node = node # : _InnerClassNode
            build_inner_class_entity(node: inner_class_node, syntax: syntax, indentation: indentation)
          when :module
            build_module_entity(node: node, has_namespaces: has_namespaces, syntax: syntax, indentation: indentation)
          else
            raise "Unknown node type: #{node.type}"
          end
        end

        def build_class_entity(node:, syntax:, indentation:)
          methods = build_class_methods_with_inner_classes(node: node, syntax: syntax)
          param = Formatter::Diagram::PlantUML::EntityParam.new(
            name: node.name,
            methods: methods,
            syntax: syntax,
            indentation: indentation
          )
          Formatter::Diagram::PlantUML::Entity::ClassEntity.new(param)
        end

        def build_module_entity(node:, has_namespaces:, syntax:, indentation:)
          methods = syntax.method_signatures(node.methods_ordered_by_visibility_and_type)
          if has_namespaces
            param = Formatter::Diagram::PlantUML::EntityParam.new(
              name: node.name,
              methods: methods,
              syntax: syntax,
              indentation: indentation
            )
            Formatter::Diagram::PlantUML::Entity::ModuleAsClassEntity.new(param)
          else
            Formatter::Diagram::PlantUML::Entity::ModuleEntity.new(
              name: node.name,
              methods: methods,
              syntax: syntax,
              indentation: indentation
            )
          end
        end

        def build_class_methods_with_inner_classes(node:, syntax:)
          methods = syntax.method_signatures(node.methods_ordered_by_visibility_and_type)

          # インナークラスがメソッドクラスの場合、メソッドとして追加
          if node.respond_to?(:inner_classes) && !node.inner_classes.empty?
            node.inner_classes.each do |inner_class_node|
              method_signature = build_inner_class_method_signature_if_applicable(inner_class_node)
              next if method_signature.nil?

              methods << method_signature
            end
          end

          methods
        end

        def build_inner_class_method_signature_if_applicable(inner_class_node)
          return nil unless inner_class_node.inner_class_type == 'method'

          execute_method = inner_class_node.methods.find { |m| m.name == 'execute' && m.method_type == 'class' }
          return nil unless execute_method

          "    +#{inner_class_node.name.split('::').last}(): #{execute_method.return_type}"
        end

        def build_inner_class_entity(node:, syntax:, indentation:)
          if node.inner_class_type == 'method'
            # メソッドクラスの場合は何も出力しない（親クラスで処理済み）
            nil
          else
            # 通常のインナークラスの場合はpackageで囲む
            create_normal_inner_class_entity(node: node, syntax: syntax, indentation: indentation)
          end
        end

        def create_normal_inner_class_entity(node:, syntax:, indentation:)
          methods = syntax.method_signatures(node.methods_ordered_by_visibility_and_type)
          parent_class_name = extract_parent_class_name(node.name)
          package_name = "#{parent_class_name}Inner"

          param = Formatter::Diagram::PlantUML::EntityParam.new(
            name: node.name.split('::').last, # シンプルなクラス名
            package_name: package_name,
            methods: methods,
            method_classes: [],
            syntax: syntax,
            indentation: indentation
          )
          Formatter::Diagram::PlantUML::Entity::InnerClassEntity.new(param)
        end

        def extract_parent_class_name(full_name)
          parts = full_name.split('::')
          parts.size > 1 ? parts[0] : full_name
        end
      end
    end
  end
end
