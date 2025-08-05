# frozen_string_literal: true

class ResultFactory
  # 配列を定義しているクラスなのでクラスの行数がおおきくても問題ない

  # rubocop:disable Metrics/ClassLength
  class AllMethodParams
    class << self
      def all
        basic_methods +
          parametered_methods +
          block_methods
      end

      private

      def basic_methods
        [
          { type: :basic, name: 'simple_method', return_type: 'String', options: {} },
          { type: :basic, name: 'union_return', return_type: 'String | Integer | nil', options: {} },
          {
            type: :basic, name: 'void_method', return_type: 'void',
            options: {
              parameters: [
                { name: 'message', type: 'String', kind: 'required_positional' }
              ]
            }
          },
          {
            type: :basic, name: 'private_method',
            return_type: 'String', options: { visibility: 'private' }
          },
          { type: :basic, name: 'public_method', return_type: 'String', options: {} }
        ]
      end

      def parametered_methods
        positional_methods + keyword_methods + special_methods
      end

      def positional_methods
        [
          {
            type: :parametered, name: 'method_with_args', return_type: 'String',
            parameters: [
              { name: 'name', type: 'String', kind: 'required_positional' },
              { name: 'age', type: 'Integer', kind: 'required_positional' }
            ],
            options: {}
          },
          {
            type: :parametered, name: 'method_with_optional', return_type: 'String',
            parameters: [
              { name: 'name', type: 'String', kind: 'required_positional' },
              { name: 'age', type: 'Integer', kind: 'optional_positional' }
            ],
            options: {}
          }
        ]
      end

      def keyword_methods
        [
          {
            type: :parametered, name: 'method_with_keywords', return_type: 'String',
            parameters: [
              { name: 'name', type: 'String', kind: 'required_keyword' },
              { name: 'age', type: 'Integer', kind: 'required_keyword' }
            ],
            options: {}
          },
          {
            type: :parametered, name: 'method_with_optional_keywords', return_type: 'String',
            parameters: [
              { name: 'name', type: 'String', kind: 'required_keyword' },
              { name: 'age', type: 'Integer', kind: 'optional_keyword' }
            ],
            options: {}
          }
        ]
      end

      def special_methods
        [
          {
            type: :parametered, name: 'method_with_splat', return_type: 'Array[String]',
            parameters: [
              { name: 'args', type: 'String', kind: 'rest_positional' }
            ],
            options: {}
          },
          {
            type: :parametered, name: 'method_with_rest_keywords',
            return_type: 'Hash[String, String]',
            parameters: [
              { name: 'options', type: 'String', kind: 'rest_keyword' }
            ],
            options: {}
          },
          {
            type: :parametered, name: 'class_method',
            return_type: 'ComprehensiveClass',
            parameters: [
              { name: 'param', type: 'String', kind: 'required_positional' }
            ],
            options: { method_type: 'class' }
          },
          {
            type: :parametered, name: 'generic_return',
            return_type: 'Array[T]',
            parameters: [
              { name: 'value', type: 'T', kind: 'required_positional' }
            ],
            options: {}
          },
          {
            type: :parametered, name: 'overloaded_method', return_type: 'String',
            parameters: [
              { name: 'arg0', type: 'String', kind: 'required_positional' }
            ],
            options: {
              overloads: [
                {
                  parameters: [
                    { name: 'arg0', type: 'String', kind: 'required_positional' }
                  ],
                  return_type: 'String'
                },
                {
                  parameters: [
                    { name: 'arg0', type: 'Integer', kind: 'required_positional' }
                  ],
                  return_type: 'Integer'
                },
                {
                  parameters: [], # : Array[Hash[Symbol, String]]
                  return_type: 'nil'
                }
              ]
            }
          }
        ]
      end

      def block_methods
        simple_block_methods + complex_block_methods
      end

      def simple_block_methods
        [
          {
            type: :block, name: 'method_with_block',
            return_type: 'Array[String]', parameters: [],
            block: {
              parameters: [
                { name: 'block_arg0', type: 'String', kind: 'block_parameter' }
              ],
              return_type: 'void'
            },
            options: {}
          }
        ]
      end

      def complex_block_methods
        [
          {
            type: :block, name: 'complex_method',
            return_type: 'Hash[String, untyped]',
            parameters: [
              { name: 'name', type: 'String', kind: 'required_positional' },
              { name: 'age', type: 'Integer', kind: 'optional_positional' },
              { name: 'tags', type: 'String', kind: 'rest_positional' },
              { name: 'options', type: 'String', kind: 'rest_keyword' }
            ],
            block: {
              parameters: [
                { name: 'block_arg0', type: 'String', kind: 'block_parameter' }
              ],
              return_type: 'void'
            },
            options: {}
          }
        ]
      end
    end

    # rubocop:enable Metrics/ClassLength
  end
end
