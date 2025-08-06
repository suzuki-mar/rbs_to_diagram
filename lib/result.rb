# frozen_string_literal: true

require_relative 'result/node'
require_relative 'result/class_node'
require_relative 'result/method_node'
require_relative 'result/relationship_node'

class Result
  attr_reader :definitions, :parsed_at

  def initialize(definitions:)
    @definitions = definitions
    @parsed_at = Time.now
  end

  def class_definitions
    @definitions.select { |definition| definition[:type] == :class }
                .map { |definition| build_detailed_class_structure(definition) }
  end

  def module_definitions
    @definitions.select { |definition| definition[:type] == :module }
                .map { |definition| build_detailed_module_structure(definition) }
  end

  def find_relationships
    class_definitions.flat_map(&:relationships).uniq
  end

  private

  def build_detailed_class_structure(class_def)
    class_node = ClassNode.from_hash(class_def)
    add_methods_to_class_node(class_node, class_def[:methods])
    add_inheritance_relationship(class_node)
    add_delegation_relationships(class_node)
    class_node
  end

  def add_methods_to_class_node(class_node, methods)
    methods.each do |method_hash|
      method_node = MethodNode.from_hash(method_hash)
      class_node.add_child(method_node)
    end
  end

  def add_inheritance_relationship(class_node)
    return unless class_node.superclass

    inheritance_node = RelationshipNode.new(
      name: "#{class_node.superclass}_to_#{class_node.name}",
      relationship_type: :inheritance,
      from: class_node.superclass,
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

  def build_detailed_module_structure(module_def)
    {
      type: :module,
      name: module_def[:name],
      methods: module_def[:methods],
      superclass: nil,
      includes: module_def[:includes] || [],
      extends: module_def[:extends] || []
    }
  end
end
