# frozen_string_literal: true

require 'spec_helper'
require 'rbs_parser'

RSpec.describe '複雑なメソッドのパース' do
  def expect_parameter(param, expected_name, expected_type, expected_kind)
    expect(param.name).to eq(expected_name)
    expect(param.type).to eq(expected_type)
    expect(param.kind).to eq(expected_kind)
  end

  let(:file_path) { 'spec/fixtures/target_method_comprehensive_class.rbs' }
  let(:result) { RBSParser.parse(file_path) }

  let(:methods) { result.class_definitions.first.methods }

  describe 'ブロック引数の取得' do
    let(:method_with_block) { methods.find { |m| m.name == 'method_with_block' } }

    it 'finds method with block' do
      expect(method_with_block).not_to be_nil
      expect(method_with_block.parameters).to be_empty
      expect(method_with_block.return_type).to eq('Array[String]')
    end

    it 'parses block information correctly' do
      block = method_with_block.block
      expect(block).not_to be_nil
      expect(block.parameters.size).to eq(1)
      expect(block.parameters[0].type).to eq('String')
      expect(block.return_type).to eq('void')
    end
  end

  describe '戻り値の型の取得' do
    it 'parses union return types' do
      union_return = methods.find { |m| m.name == 'union_return' }
      expect(union_return).not_to be_nil
      expect(union_return.parameters).to be_empty
      expect(union_return.return_type).to eq('String | Integer | nil')
    end
  end

  describe 'メソッドの可視性の取得' do
    it 'parses private methods' do
      private_method = methods.find { |m| m.name == 'private_method' }
      expect(private_method).not_to be_nil
      expect(private_method.parameters).to be_empty
      expect(private_method.return_type).to eq('String')
      expect(private_method.visibility).to eq('private')
    end

    it 'parses public methods' do
      public_method = methods.find { |m| m.name == 'public_method' }
      expect(public_method).not_to be_nil
      expect(public_method.parameters).to be_empty
      expect(public_method.return_type).to eq('String')
      expect(public_method.visibility).to eq('public')
    end
  end

  describe 'オーバーロードメソッドの取得' do
    let(:overloaded_method) { methods.find { |m| m.name == 'overloaded_method' } }

    it 'finds overloaded method with primary signature' do
      expect(overloaded_method).not_to be_nil
      expect(overloaded_method.parameters.size).to eq(1)
      expect_parameter(overloaded_method.parameters[0], 'arg0', 'String', 'required_positional')
      expect(overloaded_method.return_type).to eq('String')
    end

    it 'has correct number of overloads' do
      expect(overloaded_method.overloads.size).to eq(3)
    end

    it 'parses first overload correctly' do
      first_overload = overloaded_method.overloads[0]
      expect(first_overload[:parameters].size).to eq(1)
      expect(first_overload[:parameters][0][:name]).to eq('arg0')
      expect(first_overload[:parameters][0][:type]).to eq('String')
      expect(first_overload[:return_type]).to eq('String')
    end

    it 'parses second overload correctly' do
      second_overload = overloaded_method.overloads[1]
      expect(second_overload[:parameters].size).to eq(1)
      expect(second_overload[:parameters][0][:name]).to eq('arg0')
      expect(second_overload[:parameters][0][:type]).to eq('Integer')
      expect(second_overload[:return_type]).to eq('Integer')
    end

    it 'parses third overload correctly' do
      third_overload = overloaded_method.overloads[2]
      expect(third_overload[:parameters]).to be_empty
      expect(third_overload[:return_type]).to eq('nil')
    end
  end
end
