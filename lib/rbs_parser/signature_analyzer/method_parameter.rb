# frozen_string_literal: true

require 'rbs'

class RBSParser
  class SignatureAnalyzer
    # メソッドパラメーター抽出を担当する内部クラス
    class MethodParameter
      def self.extract(method_type)
        params = [] # : Array[Hash[Symbol, untyped]]

        # 位置引数
        params.concat(extract_required_positional_parameters(method_type))
        params.concat(extract_optional_positional_parameters(method_type))
        params.concat(extract_rest_positional_parameters(method_type))

        # キーワード引数
        params.concat(extract_required_keyword_parameters(method_type))
        params.concat(extract_optional_keyword_parameters(method_type))
        params.concat(extract_rest_keyword_parameters(method_type))

        block_info = extract_block_parameter(method_type)

        if block_info
          { parameters: params, block: block_info }
        else
          { parameters: params }
        end
      end

      private_class_method def self.extract_block_parameter(method_type)
        return nil unless method_type.block

        block = method_type.block
        block_params = [] # : Array[Hash[Symbol, untyped]]

        # ブロックの引数を処理
        block.type.required_positionals&.each_with_index do |param, index|
          block_params << {
            name: param.name ? param.name.to_s : "block_arg#{index}",
            type: param.type.to_s
          }
        end

        {
          parameters: block_params,
          return_type: block.type.return_type.to_s
        }
      end

      private_class_method def self.extract_required_positional_parameters(method_type)
        method_type.type.required_positionals.map.with_index do |param, index|
          {
            name: param.name ? param.name.to_s : "arg#{index}",
            type: param.type.to_s,
            kind: 'required_positional'
          }
        end
      end

      private_class_method def self.extract_optional_positional_parameters(method_type)
        method_type.type.optional_positionals.map.with_index do |param, index|
          {
            name: param.name ? param.name.to_s : "opt_arg#{index}",
            type: param.type.to_s,
            kind: 'optional_positional'
          }
        end
      end

      private_class_method def self.extract_rest_positional_parameters(method_type)
        return [] unless method_type.type.rest_positionals

        rest_param = method_type.type.rest_positionals
        [{
          name: rest_param.name ? rest_param.name.to_s : 'rest_args',
          type: rest_param.type.to_s,
          kind: 'rest_positional'
        }]
      end

      private_class_method def self.extract_required_keyword_parameters(method_type)
        method_type.type.required_keywords.map do |key, value|
          {
            name: key.to_s,
            type: value.to_s,
            kind: 'required_keyword'
          }
        end
      end

      private_class_method def self.extract_optional_keyword_parameters(method_type)
        method_type.type.optional_keywords.map do |key, value|
          {
            name: key.to_s,
            type: value.to_s,
            kind: 'optional_keyword'
          }
        end
      end

      private_class_method def self.extract_rest_keyword_parameters(method_type)
        return [] unless method_type.type.rest_keywords

        rest_keyword = method_type.type.rest_keywords
        [{
          name: rest_keyword.name ? rest_keyword.name.to_s : 'rest_keywords',
          type: rest_keyword.type.to_s,
          kind: 'rest_keyword'
        }]
      end
    end
  end
end
