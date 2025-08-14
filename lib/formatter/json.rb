# frozen_string_literal: true

require 'json'
require_relative '../parameter'

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
          convert_class_definition_to_hash(node)
        else
          convert_module_definition_to_hash(node)
        end
      end
    end

    def convert_module_definition_to_hash(module_def)
      {
        type: module_def.type,
        name: module_def.name,
        superclass: nil,
        methods: module_def.methods.map { |method| convert_method_to_hash(method) },
        includes: module_def.includes,
        extends: module_def.extends
      }
    end

    def convert_class_definition_to_hash(class_def)
      {
        type: class_def.type,
        name: class_def.name,
        superclass: class_def.superclass,
        methods: class_def.methods.map { |method| convert_method_to_hash(method) },
        includes: class_def.includes,
        extends: class_def.extends
      }
    end

    def convert_method_to_hash(method)
      result = { # : Hash[Symbol, untyped]
        name: method.name,
        method_type: method.method_type,
        visibility: method.visibility,
        parameters: method.parameters.map { |param| convert_parameter_to_hash(param) },
        return_type: method.return_type,
        overloads: method.overloads
      }

      block = method.block
      if block
        block_hash = convert_block_to_hash(block) # : Hash[Symbol, untyped]
        result = result.merge(block: block_hash) # : Hash[Symbol, untyped]
      end

      result
    end

    def convert_parameter_to_hash(parameter)
      if parameter.is_a?(Parameter)
        parameter.to_hash
      else
        result = {
          name: parameter[:name],
          type: parameter[:type]
        }
        result[:kind] = parameter[:kind] if parameter[:kind]
        result
      end
    end

    def convert_block_to_hash(block)
      {
        parameters: block.parameters.map { |param| convert_parameter_to_hash(param) },
        return_type: block.return_type
      }
    end
  end
end
