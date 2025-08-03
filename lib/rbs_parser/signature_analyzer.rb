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
        superclass: nil, # TODO: 継承関係の実装
        includes: [], # TODO: includeの実装
        extends: [] # TODO: extendの実装
      }
    end

    private_class_method def self.extract_module_definition(decl)
      methods = Method.extract_from_members(decl.members)
      {
        type: :module,
        name: decl.name.to_s,
        methods: methods,
        superclass: nil,
        includes: [], # TODO: includeの実装
        extends: [] # TODO: extendの実装
      }
    end
  end
end
