# frozen_string_literal: true

module Formatter
  class Diagram
    class OutputBuilder
      class ClassDiagramsBuilder
        def self.execute(entities, syntax, namespace_entity_types)
          new(entities, syntax, namespace_entity_types).execute
        end

        private_class_method :new

        def initialize(entities, syntax, namespace_entity_types)
          @entities = entities
          @syntax = syntax
          @namespace_entity_types = namespace_entity_types
        end

        def execute
          @namespace_entity_types ||= [] # : Array[Symbol]
          namespace_types = @namespace_entity_types || [] # : Array[Symbol]
          has_namespaces = namespace_exists?(entities, namespace_types)

          diagrams = [] # : Array[String]
          non_empty_entities = select_non_empty_entities(entities)

          # builder系のメソッドに分ける
          non_empty_entities.each_with_index do |entity, index|
            diagrams.concat(build_entity_diagram_parts(entity: entity, has_namespaces: has_namespaces,
                                                       non_empty_entities: non_empty_entities, index: index))
          end

          diagrams << '' if needs_trailing_blank_line?(non_empty_entities)

          diagrams
        end

        private

        attr_reader :entities, :syntax, :namespace_entity_types

        def build_entity_diagram_parts(entity:, has_namespaces:, non_empty_entities:, index:)
          if entity.is_a?(String)
            [entity]
          else
            namespace_types = @namespace_entity_types || [] # : Array[Symbol]
            parts = build_rendered_diagrams(entity, @syntax, has_namespaces, namespace_types)

            # 最後の要素でない場合、適切な空行を追加
            if index < non_empty_entities.size - 1
              next_entity = non_empty_entities[index + 1]
              parts << '' if separator_required?(entity, next_entity)
            end

            parts
          end
        end

        def needs_trailing_blank_line?(non_empty_entities)
          syntax.class.name.include?('PlantUML') && !non_empty_entities.empty?
        end

        def select_non_empty_entities(entities)
          entities.reject { |e| e.is_a?(String) && e.empty? }
        end

        def namespace_exists?(entities, namespace_entity_types)
          namespace_types = namespace_entity_types || [] # : Array[Symbol]
          entities.any? do |entity|
            entity.is_a?(String) ? false : namespace_types.include?(entity.type)
          end
        end

        def build_rendered_diagrams(entity, syntax, has_namespaces, namespace_entity_types)
          rendered_diagrams = entity.render
          if syntax.class.name.include?('PlantUML')
            namespace_types = namespace_entity_types || [] # : Array[Symbol]
            if has_namespaces && namespace_types.include?(entity.type) && entity.type != :namespace
              [''] + rendered_diagrams
            else
              rendered_diagrams
            end
          else
            rendered_diagrams
          end
        end

        def separator_required?(current_entity, next_entity)
          namespace_types = @namespace_entity_types || [] # : Array[Symbol]
          current_is_namespace = !current_entity.is_a?(String) && namespace_types.include?(current_entity.type)
          next_is_namespace = !next_entity.is_a?(String) && namespace_types.include?(next_entity.type)

          # namespace直後またはnamespace直前には空行を追加、通常のクラス間でも空行を追加
          current_is_namespace || next_is_namespace || (!current_entity.is_a?(String) && !next_entity.is_a?(String))
        end
      end
    end
  end
end
