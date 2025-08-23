# frozen_string_literal: true

module Formatter
  class Json
    module Definition
      class Method < Base
        def self.build(method)
          parameters = convert_parameters_to_definitions(method.parameters)
          block_data = nil
          block = method.block
          block_data = convert_block(block) if block

          parameter = Formatter::Json::Parameter.new(
            name: method.name,
            method_type: method.method_type,
            visibility: method.visibility,
            parameters: parameters,
            return_type: method.return_type,
            overloads: method.overloads,
            block: block_data
          )

          new(parameter)
        end

        def self.build_from_hash(method_hash)
          parameters = convert_parameters_to_definitions(method_hash[:parameters] || [])
          block_data = method_hash[:block] ? convert_block_hash(method_hash[:block]) : nil

          parameter = Formatter::Json::Parameter.new(
            name: method_hash[:name],
            method_type: method_hash[:method_type],
            visibility: method_hash[:visibility],
            parameters: parameters,
            return_type: method_hash[:return_type],
            overloads: method_hash[:overloads] || [],
            block: block_data
          )

          new(parameter)
        end

        def self.convert_parameters_to_definitions(parameters)
          parameters.map do |param|
            param_obj = param.is_a?(::Parameter) ? param : ::Parameter.from_hash(param)
            param_obj.to_hash
          end
        end

        def self.convert_block(block)
          {
            parameters: convert_parameters_to_definitions(block.parameters),
            return_type: block.return_type
          }
        end

        def self.convert_block_hash(block_hash)
          {
            parameters: convert_parameters_to_definitions(block_hash[:parameters] || []),
            return_type: block_hash[:return_type]
          }
        end

        def initialize(parameter)
          @parameter = parameter
          # Baseクラスのto_hashメソッドが使用するインスタンス変数を設定
          @name = parameter.name
          @parameters = parameter.parameters
          @return_type = parameter.return_type
          @method_type = parameter.method_type
          @visibility = parameter.visibility
          @overloads = parameter.overloads
          @block = parameter.block
        end

        def to_hash(simple: false)
          if simple
            {
              name: @name,
              parameters: @parameters,
              return_type: @return_type
            }
          else
            # 期待される順序でハッシュを作成
            result = {
              name: @name,
              method_type: @method_type,
              visibility: @visibility,
              parameters: @parameters,
              return_type: @return_type
            }

            # nilでない値のみを追加
            result[:overloads] = @overloads if @overloads
            result[:block] = convert_value_for_hash(@block) if @block

            result
          end
        end

        private

        def convert_value_for_hash(value)
          case value
          when Array
            value.map { |item| item.respond_to?(:to_hash) ? item.to_hash : item }
          when Base
            value.to_hash
          else
            value
          end
        end

        private attr_reader :parameter, :name, :parameters, :return_type, :method_type, :visibility, :overloads, :block
      end
    end
  end
end
