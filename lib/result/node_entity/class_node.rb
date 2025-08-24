# frozen_string_literal: true

require_relative '../node'

class Result
  module NodeEntity
    class Class < Node
      attr_reader :superclass, :includes, :extends, :inner_classes

      def initialize(name:, superclass: nil, includes: [], extends: [], inner_classes: [])
        super(name: name, type: :class)
        @superclass = superclass
        @includes = includes
        @extends = extends
        @inner_classes = inner_classes
      end

      def self.from_hash(class_def)
        inner_classes = (class_def[:inner_classes] || []).map do |inner_class_hash|
          build_inner_class_node(inner_class_hash, class_def)
        end

        new(
          name: class_def[:name],
          superclass: class_def[:superclass],
          includes: class_def[:includes] || [],
          extends: class_def[:extends] || [],
          inner_classes: inner_classes
        )
      end

      private_class_method def self.build_inner_class_node(inner_class_hash, class_def)
        # 親クラス名を含めた完全な名前を作成
        full_name = "#{class_def[:name]}::#{inner_class_hash[:name]}"
        inner_class_hash_with_full_name = inner_class_hash.merge(name: full_name)

        inner_class_node = Result::NodeEntity::InnerClass.from_hash(inner_class_hash_with_full_name)

        # インナークラスにメソッドを追加
        inner_class_hash[:methods]&.each do |method_hash|
          method_node = Result::NodeEntity::Method.from_hash(method_hash)
          inner_class_node.add_child(method_node)
        end

        inner_class_node
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
