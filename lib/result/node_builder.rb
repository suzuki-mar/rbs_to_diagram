# frozen_string_literal: true

require_relative 'class_node'
require_relative 'module_node'
require_relative 'method_node'
require_relative 'relationship_node'

class Result
  class NodeBuilder
    def self.build_class_node(class_def)
      new.build_class_node(class_def)
    end

    def self.build_module_node(module_def)
      new.build_module_node(module_def)
    end

    def build_class_node(class_def)
      class_node = ClassNode.from_hash(class_def)
      add_methods_to_node(class_node, class_def[:methods])
      add_inheritance_relationship(class_node)
      add_delegation_relationships(class_node)
      class_node
    end

    def build_module_node(module_def)
      module_node = ModuleNode.from_hash(module_def)
      add_methods_to_node(module_node, module_def[:methods])
      add_include_relationships(module_node)
      add_extend_relationships(module_node)
      module_node
    end

    private

    def add_methods_to_node(node, methods)
      methods.each do |method_hash|
        method_node = MethodNode.from_hash(method_hash)
        node.add_child(method_node)
      end
    end

    def add_inheritance_relationship(class_node)
      superclass = class_node.superclass
      return unless superclass

      inheritance_node = RelationshipNode.new(
        name: "#{superclass}_to_#{class_node.name}",
        relationship_type: :inheritance,
        from: superclass,
        to: class_node.name
      )
      class_node.add_relationship(inheritance_node)
    end

    def add_delegation_relationships(class_node)
      class_node.methods.each do |method|
        next unless method.parameters.empty?
        next if builtin_class?(method.return_type)

        delegation_node = RelationshipNode.new(
          name: "#{class_node.name}_to_#{method.return_type}",
          relationship_type: :delegation,
          from: class_node.name,
          to: method.return_type
        )
        class_node.add_relationship(delegation_node)
      end
    end

    def add_include_relationships(module_node)
      module_node.includes.each do |included_module|
        include_node = RelationshipNode.new(
          name: "#{included_module}_to_#{module_node.name}",
          relationship_type: :include,
          from: included_module,
          to: module_node.name
        )
        module_node.add_relationship(include_node)
      end
    end

    def add_extend_relationships(module_node)
      module_node.extends.each do |extended_module|
        extend_node = RelationshipNode.new(
          name: "#{extended_module}_to_#{module_node.name}",
          relationship_type: :extend,
          from: extended_module,
          to: module_node.name
        )
        module_node.add_relationship(extend_node)
      end
    end

    def builtin_class?(type_name)
      return true if type_name.nil? || type_name == ''

      builtin_literals = %w[
        String Integer Float Array Hash Time IO bool void nil
      ]
      return true if builtin_literals.include?(type_name)

      regex_patterns = [
        /\AArray\[/,
        /\AHash\[/,
        /\|/,
        /\A\w+\[/
      ]
      return true if regex_patterns.any? { |r| type_name.match?(r) }

      false
    end
  end
end
