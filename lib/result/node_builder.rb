# frozen_string_literal: true

require_relative 'node_entity/class_node'
require_relative 'node_entity/module_node'
require_relative 'node_entity/method_node'
require_relative 'node_entity/relationship_node'
require_relative 'node_entity/inner_class_node'
require_relative 'relationships_adder'

class Result
  class NodeBuilder
    def self.build_class_node(class_def)
      new(class_def).build_class_node
    end

    def self.build_module_node(module_def)
      new(module_def).build_module_node
    end

    def self.build_inner_class_node(class_def)
      new(class_def).build_inner_class_node
    end

    def initialize(definition)
      @definition = definition
    end

    private_class_method :new

    attr_reader :definition

    def build_class_node
      class_node = Result::NodeEntity::Class.from_hash(definition)
      add_methods_to_node(class_node, definition[:methods])
      RelationshipsAdder.add_inheritance(class_node)
      RelationshipsAdder.add_delegation(class_node)
      class_node
    end

    def build_module_node
      module_node = Result::NodeEntity::Module.from_hash(definition)
      add_methods_to_node(module_node, definition[:methods])
      RelationshipsAdder.add_include(module_node)
      RelationshipsAdder.add_extend(module_node)
      module_node
    end

    def build_inner_class_node
      inner_class_node = Result::NodeEntity::InnerClass.from_hash(definition)
      add_methods_to_node(inner_class_node, definition[:methods])
      RelationshipsAdder.add_inheritance(inner_class_node)
      RelationshipsAdder.add_delegation(inner_class_node)
      inner_class_node
    end

    def add_methods_to_node(node, methods)
      methods.each do |method_hash|
        method_node = Result::NodeEntity::Method.from_hash(method_hash)
        node.add_child(method_node)
      end
    end
  end
end
