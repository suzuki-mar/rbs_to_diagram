# frozen_string_literal: true

require_relative '../node'

class Result
  module NodeEntity
    class Module < Node
      attr_reader :includes, :extends, :is_namespace

      def self.from_hash(module_hash)
        new(
          name: module_hash[:name],
          includes: module_hash[:includes] || [],
          extends: module_hash[:extends] || [],
          is_namespace: module_hash[:is_namespace] || false
        )
      end

      private_class_method :new

      def initialize(name:, includes: [], extends: [], is_namespace: false)
        super(name: name, type: :module)
        @includes = includes
        @extends = extends
        @is_namespace = is_namespace
      end

      def methods
        result = [] # : Array[Result::NodeEntity::Method]
        children.each do |child|
          result << child if child.is_a?(Result::NodeEntity::Method)
        end
        result
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

      def add_relationship(relationship_node)
        add_child(relationship_node)
      end

      def relationships
        extract_relationship_nodes
      end

      private

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
