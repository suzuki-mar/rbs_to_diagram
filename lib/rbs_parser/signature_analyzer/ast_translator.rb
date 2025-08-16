# frozen_string_literal: true

require 'rbs'
require_relative 'method'

class RBSParser
  class SignatureAnalyzer
    # RBS::ASTの詳細を隠蔽し、内部データ構造に変換するクラス
    class ASTTranslator
      class << self
        def translate_nested_declarations(members, parent_name)
          nested_declarations = find_nested_declarations(members)
          definitions = [] # : Array[Hash[Symbol, untyped]]

          nested_declarations.each do |decl|
            full_name = "#{parent_name}::#{decl.name}"

            # translate_single_declarationを使って統一的に処理し、フルネームで上書き
            definition = translate_single_declaration_with_name(decl, full_name)
            definitions << definition if definition

            # さらにネストした宣言も再帰的に処理
            if decl.respond_to?(:members)
              deeper_definitions = translate_nested_declarations(decl.members, full_name)
              definitions.concat(deeper_definitions)
            end
          end

          definitions
        end

        def translate_single_declaration_with_name(decl, full_name)
          case decl
          when RBS::AST::Declarations::Class
            RBSParser::SignatureAnalyzer.translate_class_declaration(decl, full_name)
          when RBS::AST::Declarations::Module
            RBSParser::SignatureAnalyzer.translate_module_declaration(decl, full_name)
          end
        end

        def extract_superclass(class_decl)
          class_decl.super_class&.name&.to_s
        end

        def extract_includes(members)
          members.filter_map do |member|
            next unless include_member?(member)

            member.name.to_s
          end
        end

        def extract_extends(members)
          members.filter_map do |member|
            next unless extend_member?(member)

            member.name.to_s
          end
        end

        def determine_namespace_usage(members)
          # 他のクラスやmoduleを含む場合はネームスペース
          # メソッドがない場合（空のmodule）もネームスペース
          # メソッドのみの場合は通常のmodule
          has_nested_definitions = members.any? do |member|
            class_declaration?(member) || module_declaration?(member)
          end

          has_methods = members.any? { |member| method_definition?(member) }

          # ネストした定義があるか、メソッドがない場合はネームスペース
          has_nested_definitions || !has_methods
        end

        # 型チェック用のヘルパーメソッド（パブリック）
        def class_declaration?(decl)
          decl.is_a?(RBS::AST::Declarations::Class)
        end

        def module_declaration?(decl)
          decl.is_a?(RBS::AST::Declarations::Module)
        end

        def nestable_declaration?(decl)
          class_declaration?(decl) || module_declaration?(decl)
        end

        def include_member?(member)
          member.is_a?(RBS::AST::Members::Include)
        end

        def extend_member?(member)
          member.is_a?(RBS::AST::Members::Extend)
        end

        def method_definition?(member)
          member.is_a?(RBS::AST::Members::MethodDefinition)
        end

        private

        def find_nested_declarations(members)
          members.select do |member|
            class_declaration?(member) || module_declaration?(member)
          end
        end
      end
    end
  end
end
