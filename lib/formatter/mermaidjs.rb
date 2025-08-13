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
      class_diagrams = parser_result.class_definitions.flat_map { |class_def| convert_class_to_mermaid(class_def) }
      module_diagrams = parser_result.module_definitions.flat_map { |module_def| convert_module_to_mermaid(module_def) }
      class_diagrams + module_diagrams
    end

    def convert_module_to_mermaid(module_def)
      module_name = module_def.name
      methods = module_def.methods_ordered_by_visibility_and_type
      mermaid_methods = methods.map { |method| convert_module_method_to_mermaid(method) }

      Syntax.module_definition(module_name, mermaid_methods)
    end

    def convert_module_method_to_mermaid(method)
      params_str = Syntax.format_method_parameters(method)
      block_signature = Syntax.format_block_signature(method.block)
      # Moduleのメソッドは常にstaticとして扱う
      is_static = true

      Syntax.method_signature(
        visibility: method.visibility,
        static: is_static,
        name: method.name,
        params: params_str.empty? ? [] : [params_str],
        block: block_signature,
        return_type: method.return_type
      )
    end

    def convert_method_hash_to_mermaid(method_hash)
      params_str = format_parameters_from_hash(method_hash[:parameters] || [])
      block_signature = format_block_from_hash(method_hash[:block])
      # Moduleのメソッドは基本的にstaticな性質を持つため、常にstaticとして扱う
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

      # 簡単な実装として空文字列を返す
      ''
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
