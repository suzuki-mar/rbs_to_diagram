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
      parser_result.class_definitions.flat_map { |class_def| convert_class_to_mermaid(class_def) }
    end

    def convert_class_to_mermaid(class_def)
      class_name = class_def.name
      methods = class_def.methods_ordered_by_visibility_and_type
      mermaid_methods = methods.map { |method| convert_method_to_mermaid(method) }

      Syntax.class_definition(class_name, mermaid_methods)
    end

    def convert_method_to_mermaid(method)
      params_str = Syntax.format_method_parameters(method)
      block_signature = Syntax.format_block_signature(method.block)
      is_static = method.method_type == 'class'

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
      Syntax.build_relationships(parser_result.find_relationships)
    end
  end
end
