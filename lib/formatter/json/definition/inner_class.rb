# frozen_string_literal: true

module Formatter
  class Json
    module Definition
      class InnerClass < Base
        def self.build(inner_class)
          methods = inner_class[:methods].map { |method| Method.build_from_hash(method) }
          inner_class_node = Result::NodeBuilder.build_inner_class_node(inner_class)
          type = inner_class_node.inner_class_type

          parameter = Formatter::Json::Parameter.new(
            name: inner_class[:name],
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
