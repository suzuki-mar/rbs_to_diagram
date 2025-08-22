# frozen_string_literal: true

module Formatter
  class Diagram
    class PlantUML
      class Syntax
        class EntityDefinition
          private attr_reader :indentation

          def initialize(indentation:)
            @indentation = indentation
          end

          def class(class_name, methods)
            safe_name = class_name.gsub(/\?$/, '')
            [
              "class #{safe_name} {",
              *methods,
              '}'
            ]
          end

          def module(module_name, methods)
            safe_name = module_name.gsub(/\?$/, '')
            [
              "    class #{safe_name} {",
              '        <<module>>',
              *methods,
              '    }'
            ]
          end

          def namespace(namespace_name, content)
            safe_name = namespace_name.gsub(/\?$/, '')
            [
              "package #{safe_name} {",
              *content.map { |line| "    #{line}" },
              '}'
            ]
          end
        end
      end
    end
  end
end
