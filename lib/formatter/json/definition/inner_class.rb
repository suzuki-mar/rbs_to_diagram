# frozen_string_literal: true

module Formatter
  class Json
    module Definition
      class InnerClass < Base
        def self.build(inner_class)
          methods = inner_class.methods.map { |method| Method.build(method) }
          type = inner_class.inner_class_type
          # 完全名から短い名前を抽出
          short_name = inner_class.name.split('::').last

          parameter = Formatter::Json::Parameter.new(
            name: short_name,
            type: type,
            methods: methods
          )

          new(parameter)
        end

        def initialize(parameter)
          @parameter = parameter
          # to_hashメソッドで直接使用するため、インスタンス変数も設定
          @name = parameter.name
          @type = parameter.type
          @methods = parameter.methods
        end

        def to_hash
          {
            name: @name,
            type: @type,
            methods: @methods.map { |m| m.to_hash(simple: true) }
          }
        end

        private attr_reader :parameter, :name, :type, :methods
      end
    end
  end
end
