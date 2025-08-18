# frozen_string_literal: true

require_relative 'plantuml/syntax'
require_relative 'plantuml/entity/base'
require_relative 'plantuml/entity/class_entity'
require_relative 'plantuml/entity/module_entity'
require_relative 'plantuml/entity/module_as_class_entity'
require_relative 'plantuml/entity/namespace'
require_relative 'plantuml/entity/namespace_class'
require_relative 'plantuml/entity/empty_namespace'
require_relative 'plantuml/entity_builder/regular_entities'
require_relative 'plantuml/entity_builder/namespace_entities'
require_relative 'plantuml/entity_builder/empty_namespace_entities'
require_relative 'namespace_collection'
require_relative 'plantuml/namespace_collection_spec'

module Formatter
  class Diagram
    class PlantUML
      def format(parser_result)
        @diagram_formatter.format(parser_result)
      end

      def syntax
        indentation = ::Formatter::Diagram::Indentation.new
        Syntax.new(indentation: indentation)
      end

      def entity_builder(parser_result, _namespace_collection)
        indentation = ::Formatter::Diagram::Indentation.new
        spec = NamespaceCollectionSpec.new
        plantuml_namespace_collection = ::Formatter::Diagram::NamespaceCollection.new(parser_result, spec: spec)
        plantuml_syntax = Syntax.new(indentation: indentation)

        {
          namespace_entities: EntityBuilder::NamespaceEntities.build(plantuml_namespace_collection, plantuml_syntax,
                                                                     indentation),
          regular_entities: EntityBuilder::RegularEntities.build(parser_result, plantuml_namespace_collection,
                                                                 plantuml_syntax, indentation),
          empty_namespace_entities: EntityBuilder::EmptyNamespaceEntities.build(plantuml_namespace_collection,
                                                                                plantuml_syntax, indentation)
        }
      end

      def namespace_collection(parser_result)
        spec = NamespaceCollectionSpec.new
        ::Formatter::Diagram::NamespaceCollection.new(parser_result, spec: spec)
      end

      def trailing_newline?
        true
      end
    end
  end
end
