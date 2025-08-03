# frozen_string_literal: true

require_relative 'node'
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

    class Block
      attr_reader :parameters, :return_type

      def initialize(parameters:, return_type:)
        @parameters = parameters
        @return_type = return_type
      end
    end

    private_constant :Block

    # ファクトリーメソッド: ハッシュからMethodNodeを構築
    def self.from_hash(method_hash)
      parameters = build_parameters(method_hash[:parameters])
      block = build_block(method_hash[:block])

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

    private_class_method def self.build_block(block_hash)
      return nil unless block_hash

      block_parameters = block_hash[:parameters].map do |param_obj|
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

      Block.new(
        parameters: block_parameters,
        return_type: block_hash[:return_type]
      )
    end
  end
end
