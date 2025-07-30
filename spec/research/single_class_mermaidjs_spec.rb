# frozen_string_literal: true

require 'rbs'

# Mermaid.js出力形式の学習テスト - クラス図生成のためのフォーマット調査
describe 'Mermaid.js出力形式の学習テスト' do
  describe 'シンプルなクラスのMermaid.js表現' do
    let(:simple_class_content) do
      <<~RBS
        class User
          attr_reader name: String
          attr_reader age: Integer

          def initialize: (name: String, age: Integer) -> void
          def greeting: () -> String
        end
      RBS
    end

    let(:user_class) do
      buffer = RBS::Buffer.new(content: simple_class_content, name: 'user.rbs')
      _, _, declarations = RBS::Parser.parse_signature(buffer)
      declarations.first
    end

    it 'クラス名をMermaid.js形式で表現できる' do
      class_name = user_class.name.to_s

      mermaid_class_definition = "class #{class_name} {"
      expect(mermaid_class_definition).to eq('class User {')
    end

    it 'attr_readerをMermaid.js形式で表現できる' do
      attr_readers = user_class.members.select { |m| m.is_a?(RBS::AST::Members::AttrReader) }

      mermaid_attributes = attr_readers.map do |attr|
        "+#{attr.name} : #{attr.type}"
      end

      expect(mermaid_attributes).to contain_exactly(
        '+name : String',
        '+age : Integer'
      )
    end

    it 'メソッドをMermaid.js形式で表現できる' do
      methods = user_class.members.select { |m| m.is_a?(RBS::AST::Members::MethodDefinition) }

      mermaid_methods = methods.map do |method|
        method_type = method.overloads.first.method_type

        # 位置引数とキーワード引数の両方を考慮
        positional_params = method_type.type.required_positionals.map { |p| p.type.to_s }
        keyword_params = method_type.type.required_keywords.values.map(&:to_s)
        all_params = positional_params + keyword_params

        params_str = all_params.join(', ')
        return_type = method_type.type.return_type.to_s

        if params_str.empty?
          "+#{method.name}() #{return_type}"
        else
          "+#{method.name}(#{params_str}) #{return_type}"
        end
      end

      expect(mermaid_methods).to contain_exactly(
        '+initialize(String, Integer) void',
        '+greeting() String'
      )
    end

    it '完全なMermaid.jsクラス図を生成できる' do
      class_name = user_class.name.to_s

      # attr_readers
      attr_readers = user_class.members.select { |m| m.is_a?(RBS::AST::Members::AttrReader) }
      mermaid_attributes = attr_readers.map { |attr| "        +#{attr.name} : #{attr.type}" }

      # methods
      methods = user_class.members.select { |m| m.is_a?(RBS::AST::Members::MethodDefinition) }
      mermaid_methods = methods.map do |method|
        method_type = method.overloads.first.method_type

        # 位置引数とキーワード引数の両方を考慮
        positional_params = method_type.type.required_positionals.map { |p| p.type.to_s }
        keyword_params = method_type.type.required_keywords.values.map(&:to_s)
        all_params = positional_params + keyword_params

        params_str = all_params.join(', ')
        return_type = method_type.type.return_type.to_s

        if params_str.empty?
          "        +#{method.name}() #{return_type}"
        else
          "        +#{method.name}(#{params_str}) #{return_type}"
        end
      end

      mermaid_diagram = [
        'classDiagram',
        "    class #{class_name} {",
        *mermaid_attributes,
        *mermaid_methods,
        '    }'
      ].join("\n")

      expected_diagram = <<~MERMAID.strip
        classDiagram
            class User {
                +name : String
                +age : Integer
                +initialize(String, Integer) void
                +greeting() String
            }
      MERMAID

      expect(mermaid_diagram).to eq(expected_diagram)
    end

    it 'Mermaid.js出力を画面に表示する' do
      class_name = user_class.name.to_s

      # attr_readers
      attr_readers = user_class.members.select { |m| m.is_a?(RBS::AST::Members::AttrReader) }
      mermaid_attributes = attr_readers.map { |attr| "        +#{attr.name} : #{attr.type}" }

      # methods
      methods = user_class.members.select { |m| m.is_a?(RBS::AST::Members::MethodDefinition) }
      mermaid_methods = methods.map do |method|
        method_type = method.overloads.first.method_type

        # 位置引数とキーワード引数の両方を考慮
        positional_params = method_type.type.required_positionals.map { |p| p.type.to_s }
        keyword_params = method_type.type.required_keywords.values.map(&:to_s)
        all_params = positional_params + keyword_params

        params_str = all_params.join(', ')
        return_type = method_type.type.return_type.to_s

        if params_str.empty?
          "        +#{method.name}() #{return_type}"
        else
          "        +#{method.name}(#{params_str}) #{return_type}"
        end
      end

      mermaid_diagram = [
        'classDiagram',
        "    class #{class_name} {",
        *mermaid_attributes,
        *mermaid_methods,
        '    }'
      ].join("\n")

      puts "\n=== Mermaid.js出力 ==="
      puts mermaid_diagram
      puts "=====================\n"

      expect(mermaid_diagram).to include('classDiagram')
    end
  end

  describe 'オプション引数の表現' do
    let(:optional_args_content) do
      <<~RBS
        class OptionalArgsClass
          def method_with_optional: (String name, ?Integer age) -> String
        end
      RBS
    end

    let(:optional_class) do
      buffer = RBS::Buffer.new(content: optional_args_content, name: 'optional.rbs')
      _, _, declarations = RBS::Parser.parse_signature(buffer)
      declarations.first
    end

    it 'オプション引数をMermaid.js形式で表現できる' do
      methods = optional_class.members.select { |m| m.is_a?(RBS::AST::Members::MethodDefinition) }
      method = methods.first
      method_type = method.overloads.first.method_type

      # 必須位置引数
      required_params = method_type.type.required_positionals.map { |p| p.type.to_s }
      # オプション位置引数
      optional_params = method_type.type.optional_positionals.map { |p| "#{p.type}?" }

      all_params = required_params + optional_params
      params_str = all_params.join(', ')
      return_type = method_type.type.return_type.to_s

      mermaid_method = "+#{method.name}(#{params_str}) #{return_type}"

      expect(mermaid_method).to eq('+method_with_optional(String, Integer?) String')
    end

    it 'オプション引数のMermaid.js出力を画面に表示する' do
      methods = optional_class.members.select { |m| m.is_a?(RBS::AST::Members::MethodDefinition) }
      method = methods.first
      method_type = method.overloads.first.method_type

      # 必須位置引数
      required_params = method_type.type.required_positionals.map { |p| p.type.to_s }
      # オプション位置引数
      optional_params = method_type.type.optional_positionals.map { |p| "#{p.type}?" }

      all_params = required_params + optional_params
      params_str = all_params.join(', ')
      return_type = method_type.type.return_type.to_s

      mermaid_diagram = [
        'classDiagram',
        '    class OptionalArgsClass {',
        "        +#{method.name}(#{params_str}) #{return_type}",
        '    }'
      ].join("\n")

      puts "\n=== オプション引数のMermaid.js出力 ==="
      puts mermaid_diagram
      puts "===============================\n"

      expect(mermaid_diagram).to include('Integer?')
    end
  end

  describe '可変長引数の表現' do
    let(:splat_args_content) do
      <<~RBS
        class SplatArgsClass
          def method_with_splat: (*String args) -> Array[String]
        end
      RBS
    end

    let(:splat_class) do
      buffer = RBS::Buffer.new(content: splat_args_content, name: 'splat.rbs')
      _, _, declarations = RBS::Parser.parse_signature(buffer)
      declarations.first
    end

    it '可変長引数をMermaid.js形式で表現できる' do
      methods = splat_class.members.select { |m| m.is_a?(RBS::AST::Members::MethodDefinition) }
      method = methods.first
      method_type = method.overloads.first.method_type

      # 可変長引数
      rest_positionals = method_type.type.rest_positionals
      params_str = if rest_positionals
                     "*#{rest_positionals.type}"
                   else
                     ''
                   end

      return_type = method_type.type.return_type.to_s

      mermaid_method = "+#{method.name}(#{params_str}) #{return_type}"

      expect(mermaid_method).to eq('+method_with_splat(*String) Array[String]')
    end

    it '可変長引数のMermaid.js出力を画面に表示する' do
      methods = splat_class.members.select { |m| m.is_a?(RBS::AST::Members::MethodDefinition) }
      method = methods.first
      method_type = method.overloads.first.method_type

      # 可変長引数
      rest_positionals = method_type.type.rest_positionals
      params_str = if rest_positionals
                     "*#{rest_positionals.type}"
                   else
                     ''
                   end

      return_type = method_type.type.return_type.to_s

      mermaid_diagram = [
        'classDiagram',
        '    class SplatArgsClass {',
        "        +#{method.name}(#{params_str}) #{return_type}",
        '    }'
      ].join("\n")

      puts "\n=== 可変長引数のMermaid.js出力 ==="
      puts mermaid_diagram
      puts "=============================\n"

      expect(mermaid_diagram).to include('*String')
    end
  end
end
