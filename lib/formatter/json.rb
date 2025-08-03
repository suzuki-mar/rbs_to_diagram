# frozen_string_literal: true

require 'json'
require_relative '../parameter'

# JSONフォーマッター（コントロールオブジェクト）
class Formatter
  class JSON
    def format(parser_result)
      structure = build_structure(parser_result)

      ::JSON.pretty_generate({
                               file_path: parser_result.file_info[:file_path],
                               structure: structure
                             })
    end

    private

    def build_structure(parser_result)
      # ClassDefinitionオブジェクトをHashに変換
      class_hashes = parser_result.class_definitions.map { |class_def| convert_class_definition_to_hash(class_def) }

      # Resultクラスから既に詳細構造が返されるので、それらを結合するだけ
      class_hashes + parser_result.module_definitions
    end

    def convert_class_definition_to_hash(class_def)
      {
        type: class_def.type,
        name: class_def.name,
        superclass: class_def.superclass,
        methods: class_def.methods.map { |method| convert_method_to_hash(method) },
        includes: class_def.includes,
        extends: class_def.extends
      }
    end

    def convert_method_to_hash(method)
      result = { # : Hash[Symbol, untyped]
        name: method.name,
        method_type: method.method_type,
        visibility: method.visibility,
        parameters: method.parameters.map { |param| convert_parameter_to_hash(param) },
        return_type: method.return_type,
        overloads: method.overloads
      }

      # ブロックがある場合のみblockフィールドを追加
      if method.block
        block_hash = convert_block_to_hash(method.block) # : Hash[Symbol, untyped]
        result = result.merge(block: block_hash) # : Hash[Symbol, untyped]
      end

      result
    end

    def convert_parameter_to_hash(parameter)
      if parameter.is_a?(Parameter)
        parameter.to_hash
      else
        # ハッシュの場合でもkindフィールドを含める
        result = {
          name: parameter[:name],
          type: parameter[:type]
        }
        result[:kind] = parameter[:kind] if parameter[:kind]
        result
      end
    end

    def convert_block_to_hash(block)
      {
        parameters: block.parameters.map { |param| convert_parameter_to_hash(param) },
        return_type: block.return_type
      }
    end
  end
end
