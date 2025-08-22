# frozen_string_literal: true

require_relative 'node'
require_relative 'block_node'
require_relative '../parameter'

class Result
  # メソッドを表すノード
  class MethodNode < Node
    attr_reader :method_type, :visibility, :parameters, :return_type, :overloads, :block

    # データクラスなので引数が多くても問題ない
    # rubocop:disable Metrics/ParameterLists
    def initialize(name:, method_type:, visibility:, parameters:, return_type:, overloads: [], block: nil)
      super(name: name, type: :method)
      @method_type = method_type
      @visibility = visibility
      @parameters = parameters
      @return_type = return_type
      @overloads = overloads
      @block = block
    end
    # rubocop:enable Metrics/ParameterLists

    def to_visibility_str
      case visibility
      when 'public' then '+'
      when 'private' then '-'
      when 'protected' then '#'
      else ''
      end
    end

    def to_static_str(format_type = :plantuml)
      return '' unless method_type == 'class'

      case format_type
      when :plantuml
        '{static} '
      when :mermaidjs
        '<<static>> '
      else
        ''
      end
    end

    def to_params_str
      (parameters || []).map { |p| param_signature(p) }.join(', ')
    end

    def to_block_str
      current_block = block
      return '' unless current_block

      block_params_str = current_block.parameters.map(&:type).join(', ')
      " &block(#{block_params_str}) -> #{current_block.return_type}"
    end

    def to_return_type_str(format_type = :plantuml)
      return '' unless return_type

      case format_type
      when :plantuml
        " : #{return_type}"
      when :mermaidjs
        " #{return_type}"
      else
        ''
      end
    end

    # ファクトリーメソッド: ハッシュからMethodNodeを構築
    def self.from_hash(method_hash)
      parameters = build_parameters(method_hash[:parameters])
      block = Result::BlockNode.from_hash(method_hash[:block])

      new(
        name: method_hash[:name],
        method_type: method_hash[:method_type],
        visibility: method_hash[:visibility],
        parameters: parameters,
        return_type: method_hash[:return_type],
        overloads: method_hash[:overloads] || [],
        block: block
      )
    end

    private

    def param_signature(param)
      name = param.name
      type = param.type
      kind = param.kind
      case kind
      when 'optional_positional', 'optional_keyword'
        "#{name}?: #{type}"
      when 'rest_positional'
        "*#{name}: #{type}"
      when 'rest_keyword'
        "**#{name}: #{type}"
      else
        "#{name}: #{type}"
      end
    end

    private_class_method def self.build_parameters(param_objects)
      param_objects.map do |param_obj|
        if param_obj.is_a?(Hash)
          Parameter.new(
            name: param_obj[:name],
            type: param_obj[:type],
            kind: param_obj[:kind]
          )
        else
          param_obj
        end
      end
    end
  end
end
