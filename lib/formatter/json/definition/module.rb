# frozen_string_literal: true

module Formatter
  class Json
    module Definition
      class Module < Base
        def self.build(module_def)
          methods = module_def.methods.map { |method| Method.build(method) }

          parameter = Formatter::Json::Parameter.new(
            type: module_def.type,
            name: module_def.name,
            superclass: nil, # モジュールは常にsuperclass: null
            methods: methods,
            includes: module_def.includes,
            extends: module_def.extends,
            is_namespace: module_def.is_namespace
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
          @is_namespace = parameter.is_namespace
        end

        private

        def should_output_to_json?(key, value)
          if key == :superclass
            true # superclassは常に出力（nullでも）
          else
            super
          end
        end

        private attr_reader :parameter, :type, :name, :superclass, :methods, :includes, :extends, :is_namespace
      end
    end
  end
end
