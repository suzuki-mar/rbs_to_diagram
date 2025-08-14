# frozen_string_literal: true

class Formatter
  class JSON
    # JSON出力用の統一データクラス
    class Definition
      attr_reader :type, :name, :superclass, :methods, :includes, :extends, :method_type, :visibility, :parameters,
                  :return_type, :overloads, :block, :kind

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
        kind: nil
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
        when Definition
          value.to_hash
        else
          value
        end
      end
    end
  end
end
