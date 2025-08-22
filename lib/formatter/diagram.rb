# frozen_string_literal: true

require_relative 'diagram/mermaidjs'
require_relative 'diagram/plantuml'
require_relative 'diagram/output_builder'
require 'forwardable'

module Formatter
  class Diagram
    def initialize(factory_key)
      factory =
        case factory_key
        when :mermaidjs
          Formatter::Diagram::MermaidJS.new
        when :plantuml
          Formatter::Diagram::PlantUML.new
        else
          raise ArgumentError, "Unknown diagram format: #{factory_key}"
        end
      @factory = factory
      @trailing_newline = factory.trailing_newline?
    end

    def format(parser_result)
      @parser_result = parser_result
      diagram_context = prepare_diagram_context(parser_result)

      output = Formatter::Diagram::OutputBuilder.execute(diagram_context)
      result = output.join("\n")
      trailing_newline ? "#{result}\n" : result
    end

    private

    attr_reader :factory, :trailing_newline, :parser_result

    def prepare_diagram_context(parser_result)
      namespace_collection = factory.namespace_collection(parser_result)
      entity_builder       = factory.entity_builder(parser_result, namespace_collection)

      # 一行がながいためif文を使っている
      entity_hash = if entity_builder.respond_to?(:build_entities)
                      entity_builder.build_entities
                    else
                      entity_builder
                    end

      # 元の順序を保持：namespace -> regular -> empty_namespace
      entities = merge_entities_in_order(entity_hash)
      namespace_entity_types = parser_result.namespace_entity_types || [] # : Array[Symbol]

      {
        syntax: factory.syntax(parser_result),
        namespace_collection: namespace_collection,
        entity_builder: entity_builder,
        entities: entities,
        entity_hash: entity_hash,
        namespace_entity_types: namespace_entity_types,
        has_namespaces: namespaces?(entities, namespace_entity_types),
        trailing_newline: factory.trailing_newline?,
        parser_result: parser_result
      }
    end

    def merge_entities_in_order(entity_hash)
      # :return Array[untyped]
      buckets = %i[namespace_entities regular_entities empty_namespace_entities]

      buckets.each_with_object([]) do |key, acc|
        list = Array(entity_hash[key]) # nil 安全化
        acc.concat(list) unless list.empty?
      end
    end

    def namespaces?(entities, namespace_entity_types)
      entities.any? do |entity|
        !entity.is_a?(String) && namespace_entity_types.include?(entity.type)
      end
    end
  end
end
