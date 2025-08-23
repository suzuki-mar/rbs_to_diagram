# frozen_string_literal: true

require_relative '../node'
require_relative '../../parameter'

class Result
  module NodeEntity
    # ブロックを表すノード
    class Block < Node
      attr_reader :parameters, :return_type

      def initialize(parameters:, return_type:)
        super(name: 'block', type: :block)
        @parameters = parameters
        @return_type = return_type
      end

      # ファクトリーメソッド: ハッシュからBlockNodeを構築
      def self.from_hash(block_hash)
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

        new(
          parameters: block_parameters,
          return_type: block_hash[:return_type]
        )
      end
    end
  end
end
