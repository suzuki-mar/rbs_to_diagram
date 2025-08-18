# frozen_string_literal: true

require_relative 'output_builder/class_diagrams_builder'

module Formatter
  class Diagram
    class OutputBuilder
      def self.execute(diagram_context)
        new(diagram_context).execute
      end

      def initialize(diagram_context)
        @diagram_context = diagram_context
        @output = []
      end

      private_class_method :new

      def execute
        add_header_to_output
        add_diagrams_to_output
        add_notes_to_output
        add_relationships_to_output
        add_footer_to_output

        compact_blank_lines
      end

      private

      attr_reader :diagram_context, :output

      def add_header_to_output
        syntax = diagram_context[:syntax]
        output.concat(build_header(syntax))
      end

      def add_footer_to_output
        syntax = diagram_context[:syntax]
        output.concat(build_footer(syntax))
      end

      def add_diagrams_to_output
        syntax = diagram_context[:syntax]
        output.concat(build_diagrams(diagram_context, syntax))
      end

      def add_notes_to_output
        output.concat(build_notes(diagram_context[:entities]))
      end

      def add_relationships_to_output
        syntax = diagram_context[:syntax]
        output.concat(build_relationships(diagram_context[:parser_result], syntax))
      end

      def build_header(syntax)
        syntax.respond_to?(:header) && syntax.header ? [syntax.header] : []
      end

      def build_footer(syntax)
        syntax.respond_to?(:footer) && syntax.footer ? [syntax.footer] : []
      end

      def build_diagrams(diagram_context, syntax)
        diagrams = ClassDiagramsBuilder.execute(
          diagram_context[:entities],
          syntax,
          diagram_context[:namespace_entity_types]
        )
        diagrams.shift while diagrams.first == ''
        diagrams
      end

      def build_notes(entities)
        notes = [] # : Array[String]
        entities.each do |entity|
          next unless entity.respond_to?(:render_note) && entity.type == :namespace

          notes << entity.render_note
        end
        return [] if notes.empty?

        [''].concat(notes)
      end

      def build_relationships(parser_result, syntax)
        all_relationships = parser_result.find_nodes.flat_map(&:relationships).uniq
        relationships = syntax.build_relationships(all_relationships)
        return [] if relationships.empty?

        [
          '',
          syntax.comment('関係性の定義'),
          *relationships
        ]
      end

      def compact_blank_lines
        result = [] # : Array[String]

        output.each_with_index do |line, index|
          next result << line unless line == ''

          next unless filter_blank_lines_with_namespace_rule?(index)

          # 連続する空行は1つにまとめる
          result << line unless result.last == ''
        end

        result
      end

      def filter_blank_lines_with_namespace_rule?(index)
        # }の直後でnamespaceの直前の空行は削除

        prev_line = output[index - 1]
        next_line = output[index + 1]
        !(prev_line&.end_with?('}') && next_line&.start_with?('namespace '))
      end
    end
  end
end
