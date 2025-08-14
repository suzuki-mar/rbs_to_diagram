# frozen_string_literal: true

require_relative '../parameter'
require_relative 'mermaidjs/syntax'

class Formatter
  class MermaidJS
    def format(parser_result)
      @parser_result = parser_result

      class_diagrams = build_class_diagrams
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

    def build_class_diagrams
      parser_result.find_nodes.flat_map do |node|
        convert_node_to_mermaid(node)
      end
    end

    def convert_node_to_mermaid(node)
      node_name = node.name
      methods = node.methods_ordered_by_visibility_and_type
      mermaid_methods = methods.map { |method| convert_method_to_mermaid(method, node.type) }

      if node.type == :class
        Syntax.class_definition(node_name, mermaid_methods)
      else
        Syntax.module_definition(node_name, mermaid_methods)
      end
    end

    def convert_method_hash_to_mermaid(method_hash)
      params_str = format_parameters_from_hash(method_hash[:parameters] || [])
      block_signature = format_block_from_hash(method_hash[:block])
      is_static = true

      Syntax.method_signature(
        visibility: method_hash[:visibility] || 'public',
        static: is_static,
        name: method_hash[:name],
        params: params_str.empty? ? [] : [params_str],
        block: block_signature || '',
        return_type: method_hash[:return_type] || 'void'
      )
    end

    def format_parameters_from_hash(parameters)
      return '' if parameters.empty?

      param_strings = parameters.map do |param|
        "#{param[:name]}: #{param[:type]}"
      end
      param_strings.join(', ')
    end

    def format_block_from_hash(block_hash)
      return nil if block_hash.nil? || block_hash.empty?

      ''
    end

    def convert_method_to_mermaid(method, node_type = :class)
      params_str = Syntax.format_method_parameters(method)
      block_signature = Syntax.format_block_signature(method.block)
      is_static = node_type == :module ? true : method.method_type == 'class'

      Syntax.method_signature(
        visibility: method.visibility,
        static: is_static,
        name: method.name,
        params: params_str.empty? ? [] : [params_str], # : Array[String]
        block: block_signature,
        return_type: method.return_type
      )
    end

    def build_relationships
      all_relationships = parser_result.find_nodes.flat_map(&:relationships).uniq
      Syntax.build_relationships(all_relationships)
    end
  end
end
