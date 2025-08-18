# frozen_string_literal: true

require_relative 'mermaidjs/syntax'
require_relative 'mermaidjs/entity/base'
require_relative 'mermaidjs/entity/class'
require_relative 'mermaidjs/entity/module'
require_relative 'mermaidjs/entity/module_as_class'
require_relative 'mermaidjs/entity/namespace'
require_relative 'mermaidjs/entity/namespace_class'
require_relative 'mermaidjs/entity/empty_namespace'
require_relative 'mermaidjs/entity_builder/regular_entities'
require_relative 'mermaidjs/entity_builder/namespace_entities'
require_relative 'mermaidjs/entity_builder/empty_namespace_entities'
require_relative 'namespace_collection'
require_relative 'mermaidjs/namespace_collection_spec'

module Formatter
  class Diagram
    class MermaidJS
      def format(parser_result)
        @diagram_formatter.format(parser_result)
      end

      def syntax
        indentation = ::Formatter::Diagram::Indentation.new(level: 1)
        Syntax.new(indentation: indentation)
      end

      def entity_builder(parser_result, _namespace_collection)
        spec = NamespaceCollectionSpec.new
        mermaidjs_namespace_collection = ::Formatter::Diagram::NamespaceCollection.new(parser_result, spec: spec)
        indentation = ::Formatter::Diagram::Indentation.new(level: 1)
        mermaidjs_syntax = Syntax.new(indentation: indentation)

        {
          namespace_entities: EntityBuilder::NamespaceEntities.build(mermaidjs_namespace_collection, mermaidjs_syntax),
          regular_entities: EntityBuilder::RegularEntities.build(parser_result, mermaidjs_namespace_collection,
                                                                 mermaidjs_syntax),
          empty_namespace_entities: EntityBuilder::EmptyNamespaceEntities.build(mermaidjs_namespace_collection,
                                                                                mermaidjs_syntax)
        }
      end

      def namespace_collection(parser_result)
        spec = NamespaceCollectionSpec.new
        ::Formatter::Diagram::NamespaceCollection.new(parser_result, spec: spec)
      end

      def trailing_newline?
        false
      end
    end
  end
end
