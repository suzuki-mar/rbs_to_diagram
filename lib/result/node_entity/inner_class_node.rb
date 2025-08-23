# frozen_string_literal: true

require_relative '../node'

class Result
  module NodeEntity
    class InnerClass < Node
      attr_reader :superclass, :includes, :extends

      def initialize(name:, superclass: nil, includes: [], extends: [])
        super(name: name, type: :inner_class)
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

      def method_class?
        public_methods = select_methods_by_visibility_and_type(methods, 'public', 'instance') +
                         select_methods_by_visibility_and_type(methods, 'public', 'class')

        return false unless public_methods.size == 2

        has_initialize = public_methods.any? { |method| method.name == 'initialize' }
        has_single_class_method = select_methods_by_visibility_and_type(methods, 'public', 'class').size == 1

        has_initialize && has_single_class_method
      end

      def inner_class_type
        method_class? ? 'method' : 'normal'
      end

      private

      def extract_method_nodes
        result = [] # : Array[Result::NodeEntity::Method]
        @children.each do |child|
          result << child if child.is_a?(Result::NodeEntity::Method)
        end
        result
      end

      def extract_relationship_nodes
        result = [] # : Array[Result::NodeEntity::Relationship]
        @children.each do |child|
          result << child if child.is_a?(Result::NodeEntity::Relationship)
        end
        result
      end

      def select_methods_by_visibility_and_type(methods, visibility, method_type)
        methods.select { |m| m.visibility == visibility && m.method_type == method_type }
      end
    end
  end
end
