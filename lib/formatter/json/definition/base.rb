# frozen_string_literal: true

module Formatter
  class Json
    module Definition
      class Base
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
          return false if key == :parameter

          !value.nil?
        end

        def convert_value_for_hash(value)
          case value
          when Array
            value.map { |item| item.respond_to?(:to_hash) ? item.to_hash : item }
          when Base
            value.to_hash
          else
            value
          end
        end
      end
    end
  end
end
