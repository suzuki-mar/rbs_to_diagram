# frozen_string_literal: true

require_relative 'syntax/entity_definition'

module Formatter
  class Diagram::PlantUML
    # PlantUMLのシンタックスを生成する責務は持っていないためこのクラスは行数がながくても問題ない
    class Syntax
      private attr_reader :indentation, :entity_definition

      def initialize(indentation:)
        @indentation = indentation
        @entity_definition = EntityDefinition.new(indentation: indentation)
      end

      def header
        '@startuml'
      end

      def footer
        '@enduml'
      end

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
          "package #{safe_name} {",
          '    note "Empty namespace" as N1',
          '}'
        ]
      end

      def note_for_namespace(flattened_name, original_path)
        safe_name = flattened_name.gsub(/\?$/, '')
        "note top of #{safe_name} : Namespace: #{original_path}"
      end

      def inheritance_arrow(parent, child, label = nil)
        label_part = label ? " : #{label}" : ''
        flat_parent = parent.gsub('::', '_').gsub(/\?$/, '')
        flat_child = child.gsub('::', '_').gsub(/\?$/, '')
        "#{flat_parent} <|-- #{flat_child}#{label_part}"
      end

      def delegation_arrow(delegator, delegatee, label = nil)
        label_part = label ? " : #{label}" : ''
        flat_delegator = delegator.gsub('::', '_').gsub(/\?$/, '')
        flat_delegatee = delegatee.gsub('::', '_').gsub(/\?$/, '')
        "#{flat_delegator} --> #{flat_delegatee}#{label_part}"
      end

      def comment(text)
        "' #{text}"
      end

      # 複数箇所で使われるイナークラスなのでキーワード引数なので引数が多くて問題ない
      # rubocop:disable Metrics/ParameterLists
      def method_signature(visibility:, static:, name:, params:, block:, return_type:)
        visibility_symbol = format_visibility(visibility)
        static_prefix = static ? '{static} ' : ''
        params_str = params.empty? ? '()' : "(#{params.join(', ')})"
        block_signature = block.nil? || block.empty? ? '' : block.to_s

        "    #{visibility_symbol}#{static_prefix}#{name}#{params_str}#{block_signature} : #{return_type}"
      end
      # rubocop:enable Metrics/ParameterLists

      def method_signatures(methods)
        indent = Formatter::Diagram::Indentation.new(level: 1).to_s
        methods.map do |method|
          next method.to_s unless method.respond_to?(:name)

          visibility = method.to_visibility_str
          static = method.to_static_str(:plantuml)
          method_name = method.name
          params = method.to_params_str
          block_str = method.to_block_str
          return_type = method.to_return_type_str(:plantuml)

          "#{indent}#{visibility}#{static}#{method_name}(#{params})#{block_str}#{return_type}"
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
