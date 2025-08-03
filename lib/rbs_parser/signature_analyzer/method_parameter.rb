# frozen_string_literal: true

require 'rbs'
require_relative '../../parameter'

class RBSParser
  class SignatureAnalyzer
    # メソッドパラメーター抽出を担当する内部クラス
    class MethodParameter
      def self.extract(method_type)
        params = [] # : Array[Parameter]

        # 位置引数
        params.concat(extract_required_positional_parameters(method_type))
        params.concat(extract_optional_positional_parameters(method_type))
        params.concat(extract_rest_positional_parameters(method_type))

        # キーワード引数
        params.concat(extract_required_keyword_parameters(method_type))
        params.concat(extract_optional_keyword_parameters(method_type))
        params.concat(extract_rest_keyword_parameters(method_type))

        block_info = extract_block_parameter(method_type)

        {
          parameters: params,
          block: block_info
        }
      end

      private_class_method def self.extract_block_parameter(method_type)
        return nil unless method_type.block

        block = method_type.block
        block_params = build_block_parameters(block)

        {
          parameters: block_params,
          return_type: block.type.return_type.to_s
        }
      end

      private_class_method def self.build_block_parameters(block)
        block_params = [] # : Array[Parameter]

        # ブロックの引数を処理
        if block.type.is_a?(RBS::Types::Function) && block.type.required_positionals
          block.type.required_positionals.each_with_index do |param, index|
            block_params << Parameter.new(
              name: param.name ? param.name.to_s : "block_arg#{index}",
              type: param.type.to_s,
              kind: 'block_parameter'
            )
          end
        end

        block_params
      end

      private_class_method def self.extract_required_positional_parameters(method_type)
        return [] unless method_type.type.is_a?(RBS::Types::Function)

        method_type.type.required_positionals.map.with_index do |param, index|
          build_parameter_hash(param.name, param.type, 'required_positional', "arg#{index}")
        end
      end

      private_class_method def self.extract_optional_positional_parameters(method_type)
        return [] unless method_type.type.is_a?(RBS::Types::Function)

        method_type.type.optional_positionals.map.with_index do |param, index|
          build_parameter_hash(param.name, param.type, 'optional_positional', "opt_arg#{index}")
        end
      end

      private_class_method def self.extract_rest_positional_parameters(method_type)
        return [] unless method_type.type.is_a?(RBS::Types::Function) && method_type.type.rest_positionals

        rest_param = method_type.type.rest_positionals
        [build_parameter_hash(rest_param.name, rest_param.type, 'rest_positional', 'rest_args')]
      end

      private_class_method def self.extract_required_keyword_parameters(method_type)
        return [] unless method_type.type.is_a?(RBS::Types::Function)

        method_type.type.required_keywords.map do |key, value|
          build_parameter_hash(key, value, 'required_keyword')
        end
      end

      private_class_method def self.extract_optional_keyword_parameters(method_type)
        return [] unless method_type.type.is_a?(RBS::Types::Function)

        method_type.type.optional_keywords.map do |key, value|
          build_parameter_hash(key, value, 'optional_keyword')
        end
      end

      private_class_method def self.extract_rest_keyword_parameters(method_type)
        return [] unless method_type.type.is_a?(RBS::Types::Function) && method_type.type.rest_keywords

        rest_keyword = method_type.type.rest_keywords
        [build_parameter_hash(rest_keyword.name, rest_keyword.type, 'rest_keyword', 'rest_keywords')]
      end

      private_class_method def self.build_parameter_hash(name, type, kind, default_name = nil)
        Parameter.new(
          name: name ? name.to_s : default_name.to_s,
          type: type.to_s,
          kind: kind
        )
      end
    end
  end
end
