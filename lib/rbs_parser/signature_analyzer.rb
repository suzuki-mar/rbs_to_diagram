# frozen_string_literal: true

require 'rbs'
require_relative 'signature_analyzer/method'
require_relative 'signature_analyzer/ast_translator'

class RBSParser
  class SignatureAnalyzer
    class << self
      def analyze_content(content, file_path)
        buffer = RBS::Buffer.new(content: content, name: file_path)
        _, _, declarations = RBS::Parser.parse_signature(buffer)
        declarations
      end

      def extract_class_declarations(declarations)
        declarations.filter_map do |decl|
          next unless decl.is_a?(RBS::AST::Declarations::Class)

          {
            type: :class,
            name: decl.name.to_s,
            members: decl.members
          }
        end
      end

      def extract_module_declarations(declarations)
        declarations.filter_map do |decl|
          next unless decl.is_a?(RBS::AST::Declarations::Module)

          {
            type: :module,
            name: decl.name.to_s,
            members: decl.members
          }
        end
      end

      def extract_definitions(declarations)
        translate_declarations(declarations)
      end

      def translate_class_declaration(decl, full_name = nil)
        class_definition = {
          type: :class,
          name: full_name || decl.name.to_s,
          methods: extract_methods_from_members(decl.members),
          superclass: ASTTranslator.extract_superclass(decl),
          includes: ASTTranslator.extract_includes(decl.members),
          extends: ASTTranslator.extract_extends(decl.members)
        }

        # インナークラスがある場合は追加
        inner_classes = extract_inner_classes(decl.members)
        class_definition[:inner_classes] = inner_classes unless inner_classes.empty?

        class_definition
      end

      def translate_module_declaration(decl, full_name = nil)
        {
          type: :module,
          name: full_name || decl.name.to_s,
          methods: extract_methods_from_members(decl.members),
          superclass: nil,
          includes: ASTTranslator.extract_includes(decl.members),
          extends: ASTTranslator.extract_extends(decl.members),
          is_namespace: ASTTranslator.determine_namespace_usage(decl.members)
        }
      end

      private

      def translate_declarations(declarations)
        definitions = [] # : Array[Hash[Symbol, untyped]]

        declarations.each do |decl|
          definition = translate_single_declaration(decl)
          definitions << definition if definition

          # ネストした宣言も再帰的に処理（インナークラス以外）
          next unless ASTTranslator.nestable_declaration?(decl)

          nested_definitions = ASTTranslator.translate_nested_declarations(decl.members, decl.name.to_s)
          # インナークラスは親クラスのinner_classesに含まれるので、トップレベルには追加しない
          non_inner_class_definitions = nested_definitions.reject { |nested_def| inner_class?(nested_def, decl) }
          definitions.concat(non_inner_class_definitions)
        end

        definitions
      end

      def translate_single_declaration(decl)
        case decl
        when RBS::AST::Declarations::Class
          translate_class_declaration(decl)
        when RBS::AST::Declarations::Module
          translate_module_declaration(decl)
        end
      end

      def extract_methods_from_members(members)
        Method.extract_from_members(members)
      end

      def extract_inner_classes(members)
        inner_classes = [] # : Array[Hash[Symbol, untyped]]

        members.each do |member|
          next unless member.is_a?(RBS::AST::Declarations::Class)

          inner_class = {
            name: member.name.to_s,
            methods: extract_methods_from_members(member.members)
          }
          inner_classes << inner_class
        end

        inner_classes
      end

      def inner_class?(nested_definition, parent_declaration)
        # 親がクラスで、ネストした定義がクラスの場合はインナークラス
        parent_declaration.is_a?(RBS::AST::Declarations::Class) &&
          nested_definition[:type] == :class &&
          nested_definition[:name].start_with?("#{parent_declaration.name}::")
      end
    end
  end
end
