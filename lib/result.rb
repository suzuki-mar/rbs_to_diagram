# frozen_string_literal: true

require_relative 'result/node'
require_relative 'result/class_node'
require_relative 'result/method_node'

class Result
  attr_reader :definitions, :file_info, :parsed_at

  def initialize(definitions:, file_path:)
    @definitions = definitions
    @file_info = { file_path: file_path }
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

  private

  def build_detailed_class_structure(class_def)
    class_node = create_class_node(class_def)
    add_methods_to_class_node(class_node, class_def[:methods])
    class_node
  end

  def create_class_node(class_def)
    ClassNode.new(
      name: class_def[:name],
      superclass: nil, # TODO: 継承関係の実装
      includes: [], # TODO: includeの実装
      extends: [] # TODO: extendの実装
    )
  end

  def add_methods_to_class_node(class_node, methods)
    methods.each do |method_hash|
      method_node = MethodNode.from_hash(method_hash)
      class_node.add_child(method_node)
    end
  end

  def build_detailed_module_structure(module_def)
    {
      type: :module,
      name: module_def[:name],
      methods: module_def[:methods],
      superclass: nil,
      includes: [], # TODO: includeの実装
      extends: [] # TODO: extendの実装
    }
  end
end
