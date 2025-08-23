# frozen_string_literal: true

require 'json'
require_relative '../parameter'
require_relative 'json/definition/base'
require_relative 'json/definition/class'
require_relative 'json/definition/module'
require_relative 'json/definition/method'
require_relative 'json/definition/inner_class'

module Formatter
  class Json
    class << self
      def format(parser_result)
        structure = build_structure(parser_result)

        ::JSON.pretty_generate({
                                 structure: structure
                               })
      end

      private

      def build_structure(parser_result)
        parser_result.find_nodes.map do |node|
          if node.is_a?(Result::NodeEntity::Class)
            Formatter::Json::Definition::Class.build(node).to_hash
          else
            Formatter::Json::Definition::Module.build(node).to_hash
          end
        end
      end
    end

    class Parameter
      attr_reader :type, :name, :superclass, :methods, :includes, :extends, :inner_classes, :is_namespace, :parameters,
                  :return_type, :method_type, :visibility, :overloads, :block

      # パラメータークラスなのとキーワード引数を使用しているため、パラメーターの数が多くてもよい
      # rubocop:disable Metrics/ParameterLists
      def initialize(type: nil, name: nil, superclass: nil, methods: nil, includes: nil, extends: nil,
                     inner_classes: nil, is_namespace: nil, parameters: nil, return_type: nil,
                     method_type: nil, visibility: nil, overloads: nil, block: nil)
        @type = type
        @name = name
        @superclass = superclass
        @methods = methods
        @includes = includes
        @extends = extends
        @inner_classes = inner_classes
        @is_namespace = is_namespace
        @parameters = parameters
        @return_type = return_type
        @method_type = method_type
        @visibility = visibility
        @overloads = overloads
        @block = block
      end
      # rubocop:enable Metrics/ParameterLists
    end
  end
end
