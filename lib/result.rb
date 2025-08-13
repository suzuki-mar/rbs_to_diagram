# frozen_string_literal: true

require_relative 'result/node_builder'

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
    class_relationships = class_definitions.flat_map(&:relationships)
    module_relationships = module_definitions.flat_map(&:relationships)
    (class_relationships + module_relationships).uniq
  end

  private

  def build_detailed_class_structure(class_def)
    NodeBuilder.build_class_node(class_def)
  end

  def build_detailed_module_structure(module_def)
    NodeBuilder.build_module_node(module_def)
  end
end
