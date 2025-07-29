# frozen_string_literal: true

require 'rbs'

# RBSライブラリの学習テスト - rbs_parse_comprehensive仕様に必要な情報を調査
describe 'rbs_parse_comprehensive仕様のための学習テスト' do
  describe 'RBS::Parser.parse_signatureの正しい使い方' do
    it '戻り値の構造を理解する' do
      content = <<~RBS
        class User
          attr_reader name: String
          attr_reader age: Integer
        #{'  '}
          def initialize: (name: String, age: Integer) -> void
          def greeting: () -> String
        end

        module Authenticatable
          def authenticate: (password: String) -> bool
        end
      RBS

      buffer = RBS::Buffer.new(content: content, name: 'test.rbs')
      result = RBS::Parser.parse_signature(buffer)

      # 3つの要素: [buffer, directives, declarations]
      _, _, declarations_part = result

      expect(result.size).to eq(3)
      expect(declarations_part).to be_an(Array)
      expect(declarations_part.size).to eq(2) # User class + Authenticatable module
    end
  end

  describe 'クラス定義の詳細解析' do
    let(:class_content) do
      <<~RBS
        class User
          attr_reader name: String
          attr_reader age: Integer
        #{'  '}
          def initialize: (name: String, age: Integer) -> void
          def greeting: () -> String
        end
      RBS
    end

    let(:user_class) do
      buffer = RBS::Buffer.new(content: class_content, name: 'test.rbs')
      _, _, declarations = RBS::Parser.parse_signature(buffer)
      declarations.first
    end

    it 'クラス名を取得できる' do
      expect(user_class).to be_a(RBS::AST::Declarations::Class)
      expect(user_class.name.to_s).to eq('User')
    end

    it 'メンバー一覧を取得できる' do
      expect(user_class.members.size).to eq(4) # 2 attr_reader + 2 methods
    end

    it 'attr_readerの詳細情報を取得できる' do
      attr_readers = user_class.members.select { |m| m.is_a?(RBS::AST::Members::AttrReader) }

      expect(attr_readers.size).to eq(2)

      name_attr = attr_readers.find { |a| a.name == :name }
      expect(name_attr.type.to_s).to eq('String')

      age_attr = attr_readers.find { |a| a.name == :age }
      expect(age_attr.type.to_s).to eq('Integer')
    end

    it 'メソッド定義の詳細情報を取得できる' do
      methods = user_class.members.select { |m| m.is_a?(RBS::AST::Members::MethodDefinition) }

      expect(methods.size).to eq(2)

      # initializeメソッドの検証
      initialize_method = methods.find { |m| m.name == :initialize }
      expect(initialize_method).not_to be_nil

      method_type = initialize_method.overloads.first.method_type
      # キーワード引数の場合
      if method_type.type.required_positionals.empty? && !method_type.type.required_keywords.empty?
        expect(method_type.type.required_keywords.size).to eq(2)
      else
        # 位置引数の場合
        expect(method_type.type.required_positionals.size).to eq(2)
      end
      expect(method_type.type.return_type.to_s).to eq('void')

      # greetingメソッドの検証
      greeting_method = methods.find { |m| m.name == :greeting }
      expect(greeting_method).not_to be_nil

      greeting_type = greeting_method.overloads.first.method_type
      expect(greeting_type.type.required_positionals.size).to eq(0)
      expect(greeting_type.type.return_type.to_s).to eq('String')
    end
  end

  describe 'モジュール定義の詳細解析' do
    let(:module_content) do
      <<~RBS
        module Authenticatable
          def authenticate: (password: String) -> bool
        end
      RBS
    end

    let(:auth_module) do
      buffer = RBS::Buffer.new(content: module_content, name: 'test.rbs')
      _, _, declarations = RBS::Parser.parse_signature(buffer)
      declarations.first
    end

    it 'モジュール名を取得できる' do
      expect(auth_module).to be_a(RBS::AST::Declarations::Module)
      expect(auth_module.name.to_s).to eq('Authenticatable')
    end

    it 'モジュール内のメソッドを取得できる' do
      methods = auth_module.members.select { |m| m.is_a?(RBS::AST::Members::MethodDefinition) }

      expect(methods.size).to eq(1)

      auth_method = methods.first
      expect(auth_method.name).to eq(:authenticate)

      method_type = auth_method.overloads.first.method_type
      # キーワード引数の場合
      if method_type.type.required_positionals.empty? && !method_type.type.required_keywords.empty?
        expect(method_type.type.required_keywords.size).to eq(1)
      else
        # 位置引数の場合
        expect(method_type.type.required_positionals.size).to eq(1)
      end
      expect(method_type.type.return_type.to_s).to eq('bool')
    end
  end

  describe '複雑なメソッドパターンの解析 - rbs_parse_comprehensive用' do
    let(:comprehensive_content) do
      <<~RBS
        class ComprehensiveClass
          # 引数なしメソッド
          def simple_method: () -> String
        #{'  '}
          # 位置引数
          def method_with_args: (String name, Integer age) -> String
        #{'  '}
          # オプション引数
          def method_with_optional: (String name, ?Integer age) -> String
        #{'  '}
          # キーワード引数
          def method_with_keywords: (name: String, age: Integer) -> String
        #{'  '}
          # オプションキーワード引数
          def method_with_optional_keywords: (name: String, ?age: Integer) -> String
        #{'  '}
          # ブロック引数
          def method_with_block: () { (String) -> void } -> String
        #{'  '}
          # 可変長引数
          def method_with_splat: (*String args) -> String
        #{'  '}
          # キーワード可変長引数
          def method_with_double_splat: (**String kwargs) -> String
        #{'  '}
          # 複合引数
          def complex_method: (String name, ?Integer age, *String tags, **String options) { (String) -> void } -> String
        #{'  '}
          # オーバーロードメソッド
          def method_overload: (String) -> String
                             | (Integer) -> String
                             | () -> nil
        #{'  '}
          # クラスメソッド
          def self.class_method: () -> String
        #{'  '}
          # Union型戻り値
          def union_return: () -> (String | Integer | nil)
        #{'  '}
          # Generic型戻り値
          def generic_return: [T] (T value) -> Array[T]
        #{'  '}
          # void戻り値
          def void_method: (String message) -> void
        #{'  '}
          private
        #{'  '}
          # プライベートメソッド
          def private_method: () -> String
        #{'  '}
          protected
        #{'  '}
          # プロテクトメソッド
          def protected_method: () -> String
        end
      RBS
    end

    let(:comprehensive_class) do
      buffer = RBS::Buffer.new(content: comprehensive_content, name: 'comprehensive.rbs')
      _, _, declarations = RBS::Parser.parse_signature(buffer)
      declarations.first
    end

    it 'すべてのメソッドを取得できる' do
      methods = comprehensive_class.members.select { |m| m.is_a?(RBS::AST::Members::MethodDefinition) }

      # メソッド名の一覧を確認
      method_names = methods.map(&:name)
      expected_names = %i[
        simple_method method_with_args method_with_optional
        method_with_keywords method_with_optional_keywords
        method_with_block method_with_splat method_with_double_splat
        complex_method method_overload class_method
        union_return generic_return void_method
        private_method protected_method
      ]

      expect(method_names).to match_array(expected_names)
    end

    it '位置引数の詳細を取得できる' do
      methods = comprehensive_class.members.select { |m| m.is_a?(RBS::AST::Members::MethodDefinition) }
      method_with_args = methods.find { |m| m.name == :method_with_args }

      method_type = method_with_args.overloads.first.method_type
      positionals = method_type.type.required_positionals

      expect(positionals.size).to eq(2)
      expect(positionals[0].type.to_s).to eq('String')
      expect(positionals[1].type.to_s).to eq('Integer')
    end

    it 'オプション引数の詳細を取得できる' do
      methods = comprehensive_class.members.select { |m| m.is_a?(RBS::AST::Members::MethodDefinition) }
      method_with_optional = methods.find { |m| m.name == :method_with_optional }

      method_type = method_with_optional.overloads.first.method_type
      positionals = method_type.type.required_positionals
      optionals = method_type.type.optional_positionals

      expect(positionals.size).to eq(1)
      expect(positionals[0].type.to_s).to eq('String')
      expect(optionals.size).to eq(1)
      expect(optionals[0].type.to_s).to eq('Integer')
    end

    it 'キーワード引数の詳細を取得できる' do
      methods = comprehensive_class.members.select { |m| m.is_a?(RBS::AST::Members::MethodDefinition) }
      method_with_keywords = methods.find { |m| m.name == :method_with_keywords }

      method_type = method_with_keywords.overloads.first.method_type
      required_keywords = method_type.type.required_keywords

      expect(required_keywords.size).to eq(2)
      expect(required_keywords[:name].to_s).to eq('String')
      expect(required_keywords[:age].to_s).to eq('Integer')
    end

    it 'ブロック引数の詳細を取得できる' do
      methods = comprehensive_class.members.select { |m| m.is_a?(RBS::AST::Members::MethodDefinition) }
      method_with_block = methods.find { |m| m.name == :method_with_block }

      method_type = method_with_block.overloads.first.method_type
      block = method_type.block

      expect(block).not_to be_nil
      expect(block.type.type.required_positionals.size).to eq(1)
      expect(block.type.type.required_positionals[0].type.to_s).to eq('String')
      expect(block.type.type.return_type.to_s).to eq('void')
    end

    it '可変長引数の詳細を取得できる' do
      methods = comprehensive_class.members.select { |m| m.is_a?(RBS::AST::Members::MethodDefinition) }
      method_with_splat = methods.find { |m| m.name == :method_with_splat }

      method_type = method_with_splat.overloads.first.method_type
      rest_positionals = method_type.type.rest_positionals

      expect(rest_positionals).not_to be_nil
      expect(rest_positionals.type.to_s).to eq('String')
    end

    it 'キーワード可変長引数の詳細を取得できる' do
      methods = comprehensive_class.members.select { |m| m.is_a?(RBS::AST::Members::MethodDefinition) }
      method_with_double_splat = methods.find { |m| m.name == :method_with_double_splat }

      method_type = method_with_double_splat.overloads.first.method_type
      rest_keywords = method_type.type.rest_keywords

      expect(rest_keywords).not_to be_nil
      expect(rest_keywords.to_s).to eq('String')
    end

    it 'オーバーロードメソッドの詳細を取得できる' do
      methods = comprehensive_class.members.select { |m| m.is_a?(RBS::AST::Members::MethodDefinition) }
      method_overload = methods.find { |m| m.name == :method_overload }

      overloads = method_overload.overloads
      expect(overloads.size).to eq(3)

      # 1つ目のオーバーロード: (String) -> String
      first_overload = overloads[0].method_type
      expect(first_overload.type.required_positionals.size).to eq(1)
      expect(first_overload.type.required_positionals[0].type.to_s).to eq('String')
      expect(first_overload.type.return_type.to_s).to eq('String')

      # 2つ目のオーバーロード: (Integer) -> String
      second_overload = overloads[1].method_type
      expect(second_overload.type.required_positionals.size).to eq(1)
      expect(second_overload.type.required_positionals[0].type.to_s).to eq('Integer')
      expect(second_overload.type.return_type.to_s).to eq('String')

      # 3つ目のオーバーロード: () -> nil
      third_overload = overloads[2].method_type
      expect(third_overload.type.required_positionals.size).to eq(0)
      expect(third_overload.type.return_type.to_s).to eq('nil')
    end

    it 'クラスメソッドを識別できる' do
      methods = comprehensive_class.members.select { |m| m.is_a?(RBS::AST::Members::MethodDefinition) }
      class_method = methods.find { |m| m.name == :class_method }

      expect(class_method.kind).to eq(:singleton)
    end

    it 'インスタンスメソッドを識別できる' do
      methods = comprehensive_class.members.select { |m| m.is_a?(RBS::AST::Members::MethodDefinition) }
      instance_method = methods.find { |m| m.name == :simple_method }

      expect(instance_method.kind).to eq(:instance)
    end

    it 'メソッドの可視性を判定できる' do
      # RBSでは可視性はメンバーの順序とprivate/protectedディレクティブで決まる
      # この情報を取得するには、メンバーの順序とVisibilityディレクティブを解析する必要がある

      visibility_members = comprehensive_class.members.select { |m| m.is_a?(RBS::AST::Members::Visibility) }
      expect(visibility_members.size).to eq(2) # private, protected

      # private宣言の位置を確認
      private_index = comprehensive_class.members.find_index do |m|
        m.is_a?(RBS::AST::Members::Visibility) && m.kind == :private
      end

      # protected宣言の位置を確認
      protected_index = comprehensive_class.members.find_index do |m|
        m.is_a?(RBS::AST::Members::Visibility) && m.kind == :protected
      end

      expect(private_index).not_to be_nil
      expect(protected_index).not_to be_nil
      expect(protected_index).to be > private_index
    end

    it 'Union型の戻り値を解析できる' do
      methods = comprehensive_class.members.select { |m| m.is_a?(RBS::AST::Members::MethodDefinition) }
      union_method = methods.find { |m| m.name == :union_return }

      method_type = union_method.overloads.first.method_type
      return_type = method_type.type.return_type

      expect(return_type).to be_a(RBS::Types::Union)
      expect(return_type.types.size).to eq(3)

      type_strings = return_type.types.map(&:to_s)
      expect(type_strings).to match_array(%w[String Integer nil])
    end

    it 'Generic型の戻り値を解析できる' do
      methods = comprehensive_class.members.select { |m| m.is_a?(RBS::AST::Members::MethodDefinition) }
      generic_method = methods.find { |m| m.name == :generic_return }

      method_type = generic_method.overloads.first.method_type
      return_type = method_type.type.return_type

      expect(return_type).to be_a(RBS::Types::ClassInstance)
      expect(return_type.name.to_s).to eq('Array')
      expect(return_type.args.size).to eq(1)
      expect(return_type.args[0]).to be_a(RBS::Types::Variable)
    end
  end

  describe 'エラーケースの動作確認' do
    it '不正な構文でRBS::ParsingErrorが発生する' do
      invalid_content = File.read(File.join('spec', 'fixtures', 'target_invalid_syntax.rbs'))
      buffer = RBS::Buffer.new(content: invalid_content, name: 'invalid.rbs')

      expect do
        RBS::Parser.parse_signature(buffer)
      end.to raise_error(RBS::ParsingError)
    end

    it '空のファイルは正常に処理される' do
      empty_content = ''
      buffer = RBS::Buffer.new(content: empty_content, name: 'empty.rbs')

      result = RBS::Parser.parse_signature(buffer)
      _, _, declarations = result

      expect(declarations).to eq([])
    end
  end
end
