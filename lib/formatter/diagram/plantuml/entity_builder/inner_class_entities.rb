# frozen_string_literal: true

module Formatter
  class Diagram::PlantUML::EntityBuilder
    class InnerClassEntities
      class << self
        def build(parser_result, syntax, indentation)
          entities = [] # : Array[Formatter::Diagram::PlantUML::Entity::InnerClassEntity]

          # クラスノードからinner_classesを取得
          class_nodes = parser_result.find_nodes.select { |n| n.type == :class }

          class_nodes.each do |class_node|
            next unless class_node.respond_to?(:inner_classes) && !class_node.inner_classes.empty?

            class_node.inner_classes.each do |inner_class_node|
              entity = create_inner_class_entity(inner_class_node, syntax, indentation)
              entities << entity if entity
            end
          end

          entities
        end

        private

        def create_inner_class_entity(node, syntax, indentation)
          if node.inner_class_type == 'method'
            # メソッドクラスの場合は何も出力しない（親クラスで処理済み）
            nil
          else
            # 通常のインナークラスの場合はpackageで囲む
            create_normal_inner_class_entity(node, syntax, indentation)
          end
        end

        def create_normal_inner_class_entity(node, syntax, indentation)
          methods = syntax.method_signatures(node.methods_ordered_by_visibility_and_type)
          method_classes = collect_method_class_entities(node, syntax, indentation)
          parent_class_name = extract_parent_class_name(node.name)
          package_name = "#{parent_class_name}Inner"

          param = Formatter::Diagram::PlantUML::EntityParam.new(
            name: node.name.split('::').last,
            package_name: package_name,
            methods: methods,
            method_classes: method_classes,
            syntax: syntax,
            indentation: indentation
          )
          Formatter::Diagram::PlantUML::Entity::InnerClassEntity.new(param)
        end

        def collect_method_class_entities(node, syntax, indentation)
          execute_methods = node.methods.select do |m|
            m.respond_to?(:name) && m.name == 'execute' && m.method_type == 'class'
          end

          execute_methods.map do |execute_method|
            param = Formatter::Diagram::PlantUML::EntityParam.new(
              name: node.name.split('::').last,
              method_signature: "    +#{node.name.split('::').last}(): #{execute_method.return_type}",
              syntax: syntax,
              indentation: indentation
            )
            Formatter::Diagram::PlantUML::Entity::MethodClassEntity.new(param)
          end
        end

        def extract_parent_class_name(full_name)
          parts = full_name.split('::')
          parts.size > 1 ? parts[0] : full_name
        end
      end
    end
  end
end
