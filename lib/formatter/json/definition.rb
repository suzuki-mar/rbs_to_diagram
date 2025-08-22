# frozen_string_literal: true

# JSON出力用の統一データクラス
module Formatter
  class Json
    class JsonDefinition
      attr_reader :type, :name, :superclass, :methods, :includes, :extends, :method_type, :visibility, :parameters,
                  :return_type, :overloads, :block, :kind, :is_namespace

      # データクラスなのでパラメーターが複数あっても問題ない
      # rubocop:disable  Metrics/ParameterLists
      def initialize(
        type: nil,
        name: nil,
        superclass: nil,
        methods: nil,
        includes: nil,
        extends: nil,
        method_type: nil,
        visibility: nil,
        parameters: nil,
        return_type: nil,
        overloads: nil,
        block: nil,
        kind: nil,
        is_namespace: nil
      )
        @type = type
        @name = name
        @superclass = superclass
        @methods = methods
        @includes = includes
        @extends = extends
        @method_type = method_type
        @visibility = visibility
        @parameters = parameters
        @return_type = return_type
        @overloads = overloads
        @block = block
        @kind = kind
        @is_namespace = is_namespace
      end
      # rubocop:enable  Metrics/ParameterLists

      def to_hash
        result = {} # : Hash[Symbol, untyped]
        instance_variables.each do |var|
          key = var.to_s.delete('@').to_sym
          value = instance_variable_get(var)

          result[key] = convert_value_for_hash(value) if should_output_to_json?(key, value)
        end

        result
      end

      private

      def should_output_to_json?(key, value)
        if key == :superclass
          @type == :class || @type == :module || @type == 'class' || @type == 'module'
        else
          !value.nil?
        end
      end

      def convert_value_for_hash(value)
        case value
        when Array
          value.map { |item| item.respond_to?(:to_hash) ? item.to_hash : item }
        when Formatter::Json::JsonDefinition
          value.to_hash
        else
          value
        end
      end
    end
  end
end
