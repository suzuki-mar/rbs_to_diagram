# frozen_string_literal: true

require_relative '../parameter'

class Formatter
  class MermaidJS
    def format(parser_result)
      class_diagrams = build_class_diagrams(parser_result)

      [
        'classDiagram',
        *class_diagrams
      ].join("\n")
    end

    private

    def build_class_diagrams(parser_result)
      parser_result.class_definitions.map { |class_def| convert_class_to_mermaid(class_def) }
    end

    def convert_class_to_mermaid(class_def)
      class_name = class_def.name
      methods = class_def.methods_ordered_by_visibility_and_type

      mermaid_methods = methods.map { |method| convert_method_to_mermaid(method) }

      [
        "    class #{class_name} {",
        *mermaid_methods.map { |method_line| "        #{method_line}" },
        '    }'
      ]
    end

    def convert_method_to_mermaid(method)
      visibility_symbol = format_visibility(method.visibility)
      static_prefix = format_method_type(method.method_type)
      params_str = format_method_parameters(method)
      block_signature = format_block_signature(method.block)
      return_type = method.return_type

      if params_str.empty?
        "#{visibility_symbol}#{static_prefix}#{method.name}()#{block_signature} #{return_type}"
      else
        "#{visibility_symbol}#{static_prefix}#{method.name}(#{params_str})#{block_signature} #{return_type}"
      end
    end

    def format_visibility(visibility)
      return '-' if visibility == 'private'

      '+'
    end

    def format_method_type(method_type)
      method_type == 'class' ? '<<static>> ' : ''
    end

    def format_method_parameters(method)
      return '' if method.parameters.empty?

      method.parameters
            .filter_map { |param| format_param(param) }
            .join(', ')
    end

    # 単なるcase文だけなので複雑でも問題ない
    # rubocop:disable Metrics/CyclomaticComplexity
    def format_param(param)
      case param.kind
      when 'required_positional', nil  then param.type
      when 'optional_positional'  then "#{param.type}?"
      when 'rest_positional'      then "*#{param.type}"
      when 'required_keyword'     then "#{param.name}: #{param.type}"
      when 'optional_keyword'     then "#{param.name}?: #{param.type}"
      when 'rest_keyword'         then "**#{param.type}"
      when 'block_parameter'      then nil # ブロックは無視
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    def format_block_signature(block)
      return '' unless block

      block_params = block.parameters.map(&:type).join(', ')
      " &block(#{block_params}) -> #{block.return_type}"
    end
  end
end
