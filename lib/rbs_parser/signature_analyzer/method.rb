# frozen_string_literal: true

require 'rbs'

class RBSParser
  class SignatureAnalyzer
    # メソッド処理を担当する内部クラス
    class Method
      def self.extract_from_members(members)
        methods = [] # : Array[Hash[Symbol, untyped]]
        members.each do |member|
          method_signature = extract_signature(member)
          methods << method_signature if method_signature
        end
        methods
      end

      def self.extract_signature(member)
        case member
        when RBS::AST::Members::AttrReader
          format_attr_reader(member)
        when RBS::AST::Members::AttrWriter
          format_attr_writer(member)
        when RBS::AST::Members::AttrAccessor
          format_attr_accessor(member)
        when RBS::AST::Members::MethodDefinition
          format_method_definition(member)
        end
      end

      private_class_method def self.format_attr_reader(attr_reader)
        {
          name: attr_reader.name.to_s,
          visibility: 'public',
          parameters: [], # : Array[Hash[Symbol, untyped]]
          return_type: attr_reader.type.to_s
        }
      end

      private_class_method def self.format_attr_writer(attr_writer)
        {
          name: "#{attr_writer.name}=",
          visibility: 'public',
          parameters: [{ name: 'value', type: attr_writer.type.to_s }],
          return_type: attr_writer.type.to_s
        }
      end

      private_class_method def self.format_attr_accessor(attr_accessor)
        {
          name: attr_accessor.name.to_s,
          visibility: 'public',
          parameters: [], # : Array[Hash[Symbol, untyped]]
          return_type: attr_accessor.type.to_s
        }
      end

      private_class_method def self.format_method_definition(method_def)
        method_type = method_def.overloads.first.method_type

        positional_params = format_positional_parameters(method_type)
        keyword_params = format_keyword_parameters(method_type)
        all_params = positional_params + keyword_params

        {
          name: method_def.name.to_s,
          visibility: 'public', # TODO: 実際のvisibilityを取得
          parameters: all_params,
          return_type: method_type.type.return_type.to_s
        }
      end

      private_class_method def self.format_positional_parameters(method_type)
        method_type.type.required_positionals.map.with_index do |param, index|
          {
            name: "arg#{index}", # 位置引数には自動で名前を付与
            type: param.type.to_s
          }
        end
      end

      private_class_method def self.format_keyword_parameters(method_type)
        method_type.type.required_keywords.map do |key, value|
          {
            name: key.to_s,
            type: value.to_s
          }
        end
      end
    end
  end
end
