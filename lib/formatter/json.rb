# frozen_string_literal: true

require 'json'
require_relative '../parameter'
require_relative 'json/definition'

# JSONフォーマッター（コントロールオブジェクト）
class Formatter
  class JSON
    def format(parser_result)
      structure = build_structure(parser_result)

      ::JSON.pretty_generate({
                               structure: structure
                             })
    end

    private

    def build_structure(parser_result)
      parser_result.find_nodes.map do |node|
        if node.is_a?(Result::ClassNode)
          convert_class_definition_to_data(node).to_hash
        else
          convert_module_definition_to_data(node).to_hash
        end
      end
    end

    def convert_module_definition_to_data(module_def)
      methods = module_def.methods.map { |method| convert_method_to_data(method) }

      Definition.new(
        type: module_def.type,
        name: module_def.name,
        superclass: nil,
        methods: methods,
        includes: module_def.includes,
        extends: module_def.extends
      )
    end

    def convert_class_definition_to_data(class_def)
      methods = class_def.methods.map { |method| convert_method_to_data(method) }

      Definition.new(
        type: class_def.type,
        name: class_def.name,
        superclass: class_def.superclass,
        methods: methods,
        includes: class_def.includes,
        extends: class_def.extends
      )
    end

    def convert_method_to_data(method)
      parameters = convert_parameters_to_definitions(method.parameters)

      attributes = { # : Hash[Symbol, untyped]
        name: method.name,
        method_type: method.method_type,
        visibility: method.visibility,
        parameters: parameters,
        return_type: method.return_type,
        overloads: method.overloads
      }

      block = method.block
      if block
        block_data = convert_block_to_data(block)
        attributes = attributes.merge(block: block_data) # : Hash[Symbol, untyped]
      end

      Definition.new(**attributes)
    end

    def convert_block_to_data(block)
      parameters = convert_parameters_to_definitions(block.parameters)

      Definition.new(
        parameters: parameters,
        return_type: block.return_type
      )
    end

    def convert_parameters_to_definitions(parameters)
      parameters.map do |param|
        param_obj = param.is_a?(Parameter) ? param : Parameter.from_hash(param)
        param_obj.to_hash
      end
    end
  end
end
