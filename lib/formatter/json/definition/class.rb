# frozen_string_literal: true

module Formatter
  class Json
    module Definition
      class Class < Base
        def self.build(class_def)
          methods = class_def.methods.map { |method| Method.build(method) }
          inner_classes = class_def.inner_classes.map { |inner_class| InnerClass.build(inner_class) }

          parameter = Formatter::Json::Parameter.new(
            type: class_def.type,
            name: class_def.name,
            superclass: class_def.superclass,
            methods: methods,
            includes: class_def.includes,
            extends: class_def.extends,
            inner_classes: inner_classes.empty? ? nil : inner_classes
          )

          new(parameter)
        end

        def initialize(parameter)
          @parameter = parameter
          # Baseクラスのto_hashメソッドが使用するインスタンス変数を設定
          @type = parameter.type
          @name = parameter.name
          @superclass = parameter.superclass
          @methods = parameter.methods
          @includes = parameter.includes
          @extends = parameter.extends
          @inner_classes = parameter.inner_classes
        end

        private

        def should_output_to_json?(key, value)
          if key == :superclass
            true # superclassは常に出力（nullでも）
          else
            super
          end
        end

        private attr_reader :parameter, :type, :name, :superclass, :methods, :includes, :extends, :inner_classes
      end
    end
  end
end
