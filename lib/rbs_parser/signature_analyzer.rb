# frozen_string_literal: true

require 'rbs'
require_relative 'signature_analyzer/method'

class RBSParser
  class SignatureAnalyzer
    def self.analyze_content(content, file_path)
      buffer = RBS::Buffer.new(content: content, name: file_path)
      _, _, declarations = RBS::Parser.parse_signature(buffer)
      declarations
    end

    def self.extract_class_declarations(declarations)
      declarations.filter_map do |decl|
        next unless decl.is_a?(RBS::AST::Declarations::Class)

        {
          type: :class,
          name: decl.name.to_s,
          members: decl.members
        }
      end
    end

    def self.extract_module_declarations(declarations)
      declarations.filter_map do |decl|
        next unless decl.is_a?(RBS::AST::Declarations::Module)

        {
          type: :module,
          name: decl.name.to_s,
          members: decl.members
        }
      end
    end

    def self.extract_definitions(declarations)
      definitions = [] # : Array[Result::definition_hash]

      declarations.each do |decl|
        case decl
        when RBS::AST::Declarations::Class
          definitions << extract_class_definition(decl)
        when RBS::AST::Declarations::Module
          definitions << extract_module_definition(decl)
        end
      end

      definitions
    end

    def self.extract_methods_from_members(members)
      Method.extract_from_members(members)
    end

    private_class_method def self.extract_class_definition(decl)
      methods = Method.extract_from_members(decl.members)
      {
        type: :class,
        name: decl.name.to_s,
        methods: methods,
        superclass: decl.super_class&.name&.to_s,
        includes: extract_includes_from_members(decl.members),
        extends: extract_extends_from_members(decl.members)
      }
    end

    private_class_method def self.extract_module_definition(decl)
      methods = Method.extract_from_members(decl.members)
      is_namespace = determine_namespace_usage(decl.members)
      {
        type: :module,
        name: decl.name.to_s,
        methods: methods,
        superclass: nil,
        includes: extract_includes_from_members(decl.members),
        extends: extract_extends_from_members(decl.members),
        is_namespace: is_namespace
      }
    end

    private_class_method def self.extract_includes_from_members(members)
      members.filter_map do |member|
        next unless member.is_a?(RBS::AST::Members::Include)

        member.name.to_s
      end
    end

    private_class_method def self.extract_extends_from_members(members)
      members.filter_map do |member|
        next unless member.is_a?(RBS::AST::Members::Extend)

        member.name.to_s
      end
    end

    private_class_method def self.determine_namespace_usage(members)
      # 他のクラスやmoduleを含む場合はネームスペース
      # メソッドがない場合（空のmodule）もネームスペース
      # メソッドのみの場合は通常のmodule
      has_nested_definitions = members.any? do |member|
        member.is_a?(RBS::AST::Declarations::Class) ||
          member.is_a?(RBS::AST::Declarations::Module)
      end

      has_methods = members.any?(RBS::AST::Members::MethodDefinition)

      # ネストした定義があるか、メソッドがない場合はネームスペース
      has_nested_definitions || !has_methods
    end
  end
end
