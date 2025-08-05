# frozen_string_literal: true

require_relative '../../lib/result'
require_relative 'result_factory/method_parameter_builder'

class ResultFactory
  class << self
    def create_comprehensive_method_class_result
      create_custom_class_result(
        class_name: 'ComprehensiveClass',
        methods: MethodParameterBuilder.build_methods
      )
    end

    def create_simple_class_result(class_name: 'SimpleClass')
      simple_class_definition = { # : Result::definition_hash
        type: :class,
        name: class_name,
        superclass: nil,
        methods: [
          build_basic_method('simple_method', 'String'),
          build_parametered_method('method_with_args', 'String', [
                                     required_positional_param('name', 'String')
                                   ])
        ],
        includes: [], # : Array[String]
        extends: [] # : Array[String]
      }

      definitions = [simple_class_definition] # : Array[Result::definition_hash]
      create_result(definitions: definitions)
    end

    private

    def create_result(definitions: [])
      Result.new(definitions: definitions)
    end

    def create_custom_class_result(class_name:, methods: [])
      custom_class_definition = { # : Result::definition_hash
        type: :class,
        name: class_name,
        superclass: nil,
        methods: methods,
        includes: [], # : Array[String]
        extends: [] # : Array[String]
      }

      definitions = [custom_class_definition] # : Array[Result::definition_hash]
      create_result(definitions: definitions)
    end

    # privateメソッドかつ共通部分以外はキーワード引数なので無効にしても問題ない
    # rubocop:disable Metrics/ParameterLists
    def build_basic_method(name, return_type, parameters: [], method_type: 'instance', visibility: 'public',
                           overloads: [])
      {
        name: name,
        method_type: method_type,
        visibility: visibility,
        parameters: parameters,
        return_type: return_type,
        overloads: overloads,
        block: nil
      }
    end
    # rubocop:enable Metrics/ParameterLists

    # privateメソッドかつ共通部分以外はキーワード引数なので無効にしても問題ない
    # rubocop:disable Metrics/ParameterLists
    def build_parametered_method(name, return_type, parameters, method_type: 'instance', visibility: 'public',
                                 overloads: [])
      {
        name: name,
        method_type: method_type,
        visibility: visibility,
        parameters: parameters,
        return_type: return_type,
        overloads: overloads,
        block: nil
      }
    end
    # rubocop:enable Metrics/ParameterLists

    def required_positional_param(name, type)
      { name: name, type: type, kind: 'required_positional' }
    end
  end
end
