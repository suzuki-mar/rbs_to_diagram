# frozen_string_literal: true

require 'spec_helper'
require 'rbs_parser'

RSpec.describe 'メソッドのパラメーターのパース' do
  let(:file_path) { 'spec/fixtures/target_method_comprehensive_class.rbs' }
  let(:result) { RBSParser.parse(file_path) }

  let(:methods) { result.class_definitions.first.methods }

  describe 'パラメーターの取得' do
    where(:method_name, :expected_params) do
      [
        [
          'method_with_args',
          [
            { name: 'name', type: 'String', kind: 'required_positional' },
            { name: 'age', type: 'Integer', kind: 'required_positional' }
          ]
        ],
        [
          'method_with_optional',
          [
            { name: 'name', type: 'String', kind: 'required_positional' },
            { name: 'age', type: 'Integer', kind: 'optional_positional' }
          ]
        ],
        [
          'method_with_keywords',
          [
            { name: 'name', type: 'String', kind: 'required_keyword' },
            { name: 'age', type: 'Integer', kind: 'required_keyword' }
          ]
        ],
        [
          'method_with_optional_keywords',
          [
            { name: 'name', type: 'String', kind: 'required_keyword' },
            { name: 'age', type: 'Integer', kind: 'optional_keyword' }
          ]
        ],
        [
          'method_with_splat',
          [
            { name: 'args', type: 'String', kind: 'rest_positional' }
          ]
        ],
        [
          'class_method',
          [
            { name: 'param', type: 'String', kind: 'required_positional' }
          ]
        ],
        [
          'method_with_rest_keywords',
          [
            { name: 'options', type: 'String', kind: 'rest_keyword' }
          ]
        ],
        [
          'complex_method',
          [
            { name: 'name', type: 'String', kind: 'required_positional' },
            { name: 'age', type: 'Integer', kind: 'optional_positional' },
            { name: 'tags', type: 'String', kind: 'rest_positional' },
            { name: 'options', type: 'String', kind: 'rest_keyword' }
          ]
        ],
        [
          'void_method',
          [
            { name: 'message', type: 'String', kind: 'required_positional' }
          ]
        ],
        [
          'generic_return',
          [
            { name: 'value', type: 'T', kind: 'required_positional' }
          ]
        ]
      ]
    end

    with_them do
      it "parses #{params[:method_name]} correctly" do
        method = methods.find { |m| m.name == method_name }
        expect(method).not_to be_nil
        expect(method.parameters.size).to eq(expected_params.size)

        expected_params.each_with_index do |expected_param, index|
          actual_param = method.parameters[index]
          expect(actual_param.name).to eq(expected_param[:name])
          expect(actual_param.type).to eq(expected_param[:type])
          expect(actual_param.kind).to eq(expected_param[:kind])
        end
      end
    end
  end
end
