# frozen_string_literal: true

require 'rbs'
require_relative 'method_parameter'
require_relative '../../parameter'

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
          format_attribute(member, visibility, :reader)
        when RBS::AST::Members::AttrWriter
          format_attribute(member, visibility, :writer)
        when RBS::AST::Members::AttrAccessor
          format_attribute(member, visibility, :accessor)
        when RBS::AST::Members::MethodDefinition
          format_method_definition(member, visibility)
        end
      end

      private_class_method def self.format_attribute(attr, visibility, attr_type)
        name = case attr_type
               when :writer
                 "#{attr.name}="
               else
                 attr.name.to_s
               end

        parameters = [] # : Array[Parameter]
        if attr_type == :writer
          param = Parameter.new(name: 'value', type: attr.type.to_s, kind: 'required_positional')
          parameters << param
        end

        {
          name: name,
          method_type: 'instance',
          visibility: visibility,
          parameters: parameters.map(&:to_hash),
          return_type: attr.type.to_s,
          overloads: []
        }
      end

      private_class_method def self.format_method_definition(method_def, visibility)
        primary_method_type = method_def.overloads.first.method_type
        param_info = MethodParameter.extract(primary_method_type)
        overloads = build_overloads(method_def.overloads)

        build_method_result(method_def, visibility, param_info, primary_method_type, overloads)
      end

      private_class_method def self.build_overloads(overloads)
        result = [] # : Array[Hash[Symbol, untyped]]
        overloads.each do |overload|
          overload_method_type = overload.method_type
          overload_param_info = MethodParameter.extract(overload_method_type)
          overload_item = build_overload_item(overload_param_info, overload_method_type)
          result << overload_item
        end
        result
      end

      private_class_method def self.build_overload_item(overload_param_info, overload_method_type)
        overload_item = { # : Hash[Symbol, untyped]
          parameters: overload_param_info[:parameters].map(&:to_hash),
          return_type: overload_method_type.type.return_type.to_s
        }

        # ブロックがある場合のみblockフィールドを追加
        if overload_param_info[:block]
          overload_item[:block] = {
            parameters: overload_param_info[:block][:parameters].map(&:to_hash),
            return_type: overload_param_info[:block][:return_type]
          }
        end

        overload_item
      end

      private_class_method def self.build_method_result(method_def, visibility, param_info, primary_method_type,
                                                        overloads)
        result = { # : Hash[Symbol, untyped]
          name: method_def.name.to_s,
          method_type: method_def.kind == :singleton ? 'class' : 'instance',
          visibility: visibility,
          parameters: param_info[:parameters].map(&:to_hash),
          return_type: primary_method_type.type.return_type.to_s,
          overloads: overloads
        }

        # ブロックがある場合のみblockフィールドを追加
        if param_info[:block]
          block_hash = { # : Hash[Symbol, untyped]
            parameters: param_info[:block][:parameters].map(&:to_hash),
            return_type: param_info[:block][:return_type]
          }
          result = result.merge(block: block_hash) # : Hash[Symbol, untyped]
        end

        result
      end
    end
  end
end
