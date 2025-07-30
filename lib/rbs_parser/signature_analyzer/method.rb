# frozen_string_literal: true

require 'rbs'
require_relative 'method_parameter'

class RBSParser
  class SignatureAnalyzer
    # メソッド処理を担当する内部クラス
    class Method
      def self.extract_from_members(members)
        methods = [] # : Array[Hash[Symbol, untyped]]
        current_visibility = 'public' # デフォルトはpublic

        members.each do |member|
          case member
          when RBS::AST::Members::Private
            current_visibility = 'private'
          when RBS::AST::Members::Public
            current_visibility = 'public'
          else
            method_signature = extract_signature(member, current_visibility)
            methods << method_signature if method_signature
          end
        end
        methods
      end

      private_class_method def self.extract_signature(member, visibility)
        case member
        when RBS::AST::Members::AttrReader
          format_attr_reader(member, visibility)
        when RBS::AST::Members::AttrWriter
          format_attr_writer(member, visibility)
        when RBS::AST::Members::AttrAccessor
          format_attr_accessor(member, visibility)
        when RBS::AST::Members::MethodDefinition
          format_method_definition(member, visibility)
        end
      end

      private_class_method def self.format_attr_reader(attr_reader, visibility)
        {
          name: attr_reader.name.to_s,
          visibility: visibility,
          parameters: [], # : Array[Hash[Symbol, untyped]]
          return_type: attr_reader.type.to_s
        }
      end

      private_class_method def self.format_attr_writer(attr_writer, visibility)
        {
          name: "#{attr_writer.name}=",
          visibility: visibility,
          parameters: [{ name: 'value', type: attr_writer.type.to_s }],
          return_type: attr_writer.type.to_s
        }
      end

      private_class_method def self.format_attr_accessor(attr_accessor, visibility)
        {
          name: attr_accessor.name.to_s,
          visibility: visibility,
          parameters: [], # : Array[Hash[Symbol, untyped]]
          return_type: attr_accessor.type.to_s
        }
      end

      private_class_method def self.format_method_definition(method_def, visibility)
        primary_method_type = method_def.overloads.first.method_type
        param_info = MethodParameter.extract(primary_method_type)
        overloads = build_overloads(method_def.overloads)

        result = build_method_result(method_def, visibility, param_info, primary_method_type, overloads)
        result[:block] = param_info[:block] if param_info[:block] # steep:ignore
        result
      end

      private_class_method def self.build_overloads(overloads)
        overloads.map do |overload|
          overload_method_type = overload.method_type
          overload_param_info = MethodParameter.extract(overload_method_type)

          overload_result = {
            parameters: overload_param_info[:parameters],
            return_type: overload_method_type.type.return_type.to_s
          }
          overload_result[:block] = overload_param_info[:block] if overload_param_info[:block] # steep:ignore
          overload_result
        end
      end

      private_class_method def self.build_method_result(method_def, visibility, param_info, primary_method_type,
                                                        overloads)
        {
          name: method_def.name.to_s,
          method_type: method_def.kind == :singleton ? 'class' : 'instance',
          visibility: visibility,
          parameters: param_info[:parameters],
          return_type: primary_method_type.type.return_type.to_s,
          overloads: overloads
        }
      end
    end
  end
end
