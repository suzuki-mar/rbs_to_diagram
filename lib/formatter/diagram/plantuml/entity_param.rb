# frozen_string_literal: true

require 'forwardable'

module Formatter
  class Diagram::PlantUML
    class EntityParam
      extend Forwardable

      attr_reader :name, :package_name, :methods, :method_classes, :method_signature, :syntax, :indentation, :indent

      def_delegators :@syntax, :method_signatures
      def_delegators :@indentation, :to_s

      # パラメータークラスなので引数の数は多くても良い
      # rubocop:disable Metrics/ParameterLists
      def initialize(name:, syntax:, indentation:, package_name: nil, methods: [], method_classes: [],
                     method_signature: nil, indent: true)
        @name = name
        @package_name = package_name
        @methods = methods
        @method_classes = method_classes
        @method_signature = method_signature
        @syntax = syntax
        @indentation = indentation
        @indent = indent
      end
      # rubocop:enable Metrics/ParameterLists
    end
  end
end
