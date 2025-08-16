# frozen_string_literal: true

class Formatter
  class MermaidJS
    class Syntax
      def self.class_diagram_header
        'classDiagram'
      end

      def self.class_definition(class_name, methods)
        [
          "    class #{class_name} {",
          *methods.map { |method| "        #{method}" },
          '    }'
        ]
      end

      def self.module_definition(module_name, methods)
        [
          "    class #{module_name} {",
          '        <<module>>',
          *methods.map { |method| "        #{method}" },
          '    }'
        ]
      end

      def self.namespace_definition(namespace_name, content)
        [
          "namespace #{namespace_name} {",
          *content.map { |line| "    #{line}" },
          '}'
        ]
      end

      def self.empty_namespace_definition(namespace_name)
        [
          "class #{namespace_name} {",
          '    <<namespace>>',
          '}'
        ]
      end

      def self.note_for_namespace(flattened_name, original_path)
        "note for #{flattened_name} \"Namespace: #{original_path}\""
      end

      def self.inheritance_arrow(parent, child, label = nil)
        label_part = label ? " : \"#{label}\"" : ''
        "    #{parent} <|-- #{child}#{label_part}"
      end

      def self.delegation_arrow(delegator, delegatee, label = nil)
        label_part = label ? " : \"#{label}\"" : ''
        "    #{delegator} --> #{delegatee}#{label_part}"
      end

      def self.comment(text)
        "    %% #{text}"
      end

      # 複数箇所で使われるインナークラスなのとキーワード引数なので引数が多くて問題ない
      # rubocop:disable Metrics/ParameterLists
      def self.method_signature(visibility:, static:, name:, params:, block:, return_type:)
        visibility_symbol = format_visibility(visibility)
        static_prefix = static ? '<<static>> ' : ''
        params_str = params.empty? ? '()' : "(#{params.join(', ')})"
        block_signature = block.nil? || block.empty? ? '' : block.to_s

        "#{visibility_symbol}#{static_prefix}#{name}#{params_str}#{block_signature} #{return_type}"
      end
      # rubocop:enable Metrics/ParameterLists

      def self.format_method_parameters(method)
        return '' if method.parameters.empty?

        method.parameters
              .filter_map { |param| format_param(param) }
              .join(', ')
      end

      # 実質Mapと同じようなのとこれ以上メソッドを分けないほうがわかりやすい
      def self.format_param(param)
        return nil if param.kind == 'block_parameter'

        formats = {
          'required_positional' => { prefix: '',  suffix: '' },
          'optional_positional' => { prefix: '',  suffix: '?' },
          'rest_positional' => { prefix: '*', suffix: '' },
          'required_keyword' => { prefix: '',  suffix: '' },
          'optional_keyword' => { prefix: '',  suffix: '?' },
          'rest_keyword' => { prefix: '**', suffix: '' }
        }

        format = formats.fetch(param.kind, { prefix: '', suffix: '' })
        "#{format[:prefix]}#{param.name}#{format[:suffix]}: #{param.type}"
      end

      def self.format_block_signature(block)
        return '' unless block

        block_params = block.parameters.map(&:type).join(', ')
        " &block(#{block_params}) -> #{block.return_type}"
      end

      def self.build_relationships(relationships)
        arrows = [] # : Array[String]

        relationships.each do |rel|
          if rel.inheritance?
            arrows << inheritance_arrow(rel.from, rel.to, '継承')
          elsif rel.delegation?
            arrows << delegation_arrow(rel.from, rel.to, '委譲')
          end
        end

        arrows
      end

      private_class_method def self.format_visibility(visibility)
        visibility == 'private' ? '-' : '+'
      end
    end
  end
end
