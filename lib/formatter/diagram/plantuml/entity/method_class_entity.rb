# frozen_string_literal: true

require_relative 'base'
require_relative '../entity_param'

module Formatter
  class Diagram::PlantUML
    module Entity
      class MethodClassEntity < Base
        extend Forwardable

        private attr_reader :param

        def_delegators :@param, :method_signature, :syntax, :indentation

        def initialize(param)
          super(name: param.name, type: :method_class, syntax: param.syntax, indentation: param.indentation)
          @param = param
        end

        def render
          # メソッドクラスは親クラスのメソッドとして出力されるため、
          # 実際の出力は親クラス側で処理される
          []
        end

        def to_method_signature
          method_signature || ''
        end
      end
    end
  end
end
