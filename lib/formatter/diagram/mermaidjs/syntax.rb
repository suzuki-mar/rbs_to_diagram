# frozen_string_literal: true

require_relative 'syntax/entity_definition'

# クラスの読み込み順のため Diagram::MermaidJSと書くとエラーになる
module Formatter
  class Diagram
    class MermaidJS
      class Syntax
        private attr_reader :indentation, :entity_definition

        def initialize(indentation:)
          @indentation = indentation
          @entity_definition = EntityDefinition.new(indentation: indentation)
        end

        def header
          'classDiagram'
        end

        def footer
          nil
        end

        # class_definition
        def class_definition(class_name, methods)
          entity_definition.class(class_name, methods)
        end

        def module_definition(module_name, methods)
          entity_definition.module(module_name, methods)
        end

        def namespace_definition(namespace_name, content)
          entity_definition.namespace(namespace_name, content)
        end

        def empty_namespace_definition(namespace_name)
          safe_name = namespace_name.gsub(/\?$/, '')
          [
            "class #{safe_name} {",
            '    <<namespace>>',
            '}'
          ]
        end

        def note_for_namespace(flattened_name, original_path)
          safe_name = flattened_name.gsub(/\?$/, '')
          "note for #{safe_name} \"Namespace: #{original_path}\""
        end

        def inheritance_arrow(parent, child, label = nil)
          label_part = label ? " : \"#{label}\"" : ''
          flat_parent = parent.gsub('::', '_').gsub(/\?$/, '')
          flat_child = child.gsub('::', '_').gsub(/\?$/, '')
          "    #{flat_parent} <|-- #{flat_child}#{label_part}"
        end

        def delegation_arrow(delegator, delegatee, label = nil)
          label_part = label ? " : \"#{label}\"" : ''
          flat_delegator = delegator.gsub('::', '_').gsub(/\?$/, '')
          flat_delegatee = delegatee.gsub('::', '_').gsub(/\?$/, '')
          "    #{flat_delegator} --> #{flat_delegatee}#{label_part}"
        end

        def comment(text)
          "    %% #{text}"
        end

        # 複数箇所で使われるイナークラスなのでキーワード引数なので引数が多くて問題ない
        # rubocop:disable Metrics/ParameterLists
        def method_signature(visibility:, static:, name:, params:, block:, return_type:)
          visibility_symbol = format_visibility(visibility)
          static_prefix = static ? '<<static>> ' : ''
          params_str = params.empty? ? '()' : "(#{params.join(', ')})"
          block_signature = block.nil? || block.empty? ? '' : block.to_s

          "#{visibility_symbol}#{static_prefix}#{name}#{params_str}#{block_signature} #{return_type}"
        end
        # rubocop:enable Metrics/ParameterLists

        def method_signatures(methods)
          indent = '    ' # 4スペース固定
          methods.map do |method|
            next method.to_s unless method.respond_to?(:name)

            prefix = method.to_visibility_str
            static = method.to_static_str(:mermaidjs)
            method_name = method.name
            params = method.to_params_str
            block_str = method.to_block_str
            return_type = method.to_return_type_str(:mermaidjs)
            "#{indent}#{prefix}#{static}#{method_name}(#{params})#{block_str}#{return_type}"
          end
        end

        def build_relationships(relationships)
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

        private

        def format_visibility(visibility)
          visibility == 'private' ? '-' : '+'
        end
      end
    end
  end
end
