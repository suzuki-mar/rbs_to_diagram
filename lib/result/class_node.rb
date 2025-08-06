# frozen_string_literal: true

require_relative 'node'

class Result
  class ClassNode < Node
    attr_reader :superclass, :includes, :extends

    def initialize(name:, superclass: nil, includes: [], extends: [])
      super(name: name, type: :class)
      @superclass = superclass
      @includes = includes
      @extends = extends
    end

    def self.from_hash(class_def)
      new(
        name: class_def[:name],
        superclass: class_def[:superclass],
        includes: class_def[:includes] || [],
        extends: class_def[:extends] || []
      )
    end

    def methods
      extract_method_nodes
    end

    def relationships
      extract_relationship_nodes
    end

    def add_relationship(relationship_node)
      add_child(relationship_node)
    end

    def methods_ordered_by_visibility_and_type
      all_methods = methods

      [
        select_methods_by_visibility_and_type(all_methods, 'public', 'class'),
        select_methods_by_visibility_and_type(all_methods, 'public', 'instance'),
        select_methods_by_visibility_and_type(all_methods, 'private', 'class'),
        select_methods_by_visibility_and_type(all_methods, 'private', 'instance')
      ].flatten
    end

    private

    def extract_method_nodes
      result = [] # : Array[Result::MethodNode]
      @children.each do |child|
        result << child if child.is_a?(MethodNode)
      end
      result
    end

    def extract_relationship_nodes
      result = [] # : Array[Result::RelationshipNode]
      @children.each do |child|
        result << child if child.is_a?(RelationshipNode)
      end
      result
    end

    def select_methods_by_visibility_and_type(methods, visibility, method_type)
      methods.select { |m| m.visibility == visibility && m.method_type == method_type }
    end
  end
end
