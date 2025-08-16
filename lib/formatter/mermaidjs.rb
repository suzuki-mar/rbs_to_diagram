# frozen_string_literal: true

require_relative '../parameter'
require_relative 'mermaidjs/syntax'
require_relative 'mermaidjs/namespace_collection'
require_relative 'mermaidjs/entity_builder'
require_relative 'mermaidjs/entities'

class Formatter
  class MermaidJS
    def format(parser_result)
      @parser_result = parser_result

      diagram_data = prepare_diagram_data
      class_diagrams = build_class_diagrams(diagram_data)
      relationships = build_relationships

      output = [Syntax.class_diagram_header]
      output.concat(class_diagrams)

      unless relationships.empty?
        output << ''
        output << Syntax.comment('関係性の定義')
        output.concat(relationships)
      end

      output.join("\n")
    end

    private

    attr_reader :parser_result

    def prepare_diagram_data
      namespace_collection = NamespaceCollection.new(parser_result)
      method_converter = method(:convert_methods_to_mermaid)
      entity_builder = EntityBuilder.new(parser_result, namespace_collection, method_converter)
      entities = entity_builder.build_entities

      namespace_entity_types = %i[namespace empty_namespace]
      {
        entities: entities,
        has_namespaces: entities.any? { |entity| namespace_entity_types.include?(entity.type) }
      }
    end

    def build_class_diagrams(diagram_data)
      entities = diagram_data[:entities]
      has_namespaces = diagram_data[:has_namespaces]

      diagrams = [] # : Array[String]
      notes = [] # : Array[String]

      entities.each do |entity|
        result = entity.render_with_context(has_namespaces: has_namespaces)
        diagrams.concat(result[:diagrams])
        notes.concat(result[:notes])
      end

      # 最後にnoteを追加
      unless notes.empty?
        diagrams << ''
        diagrams.concat(notes)
      end

      diagrams
    end

    def build_relationships
      all_relationships = parser_result.find_nodes.flat_map(&:relationships).uniq
      Syntax.build_relationships(all_relationships)
    end

    def convert_methods_to_mermaid(methods, node_type)
      methods.map do |method|
        params_str = Syntax.format_method_parameters(method)
        block_signature = Syntax.format_block_signature(method.block)
        is_static = node_type == :module ? true : method.method_type == 'class'

        Syntax.method_signature(
          visibility: method.visibility,
          static: is_static,
          name: method.name,
          params: params_str.empty? ? [] : [params_str],
          block: block_signature,
          return_type: method.return_type
        )
      end
    end
  end
end
