# frozen_string_literal: true

require_relative 'result/node_builder'

class Result
  attr_reader :definitions, :parsed_at

  include Enumerable

  private_class_method :new

  def initialize(definitions:)
    @definitions = definitions
    @parsed_at = Time.now
  end

  def find_nodes
    class_nodes = @definitions.select { |definition| definition[:type] == :class }
                              .map { |definition| NodeBuilder.build_class_node(definition) }
    module_nodes = @definitions.select { |definition| definition[:type] == :module }
                               .map { |definition| NodeBuilder.build_module_node(definition) }
    class_nodes + module_nodes
  end

  def namespace_entity_types
    %i[namespace empty_namespace namespace_class]
  end

  def each(&)
    find_nodes.each(&)
  end

  def self.build(definitions)
    new(definitions: definitions)
  end
end
