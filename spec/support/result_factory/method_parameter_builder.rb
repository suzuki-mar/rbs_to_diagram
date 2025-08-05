# frozen_string_literal: true

require_relative 'all_method_params'

class ResultFactory
  class MethodParameterBuilder
    class << self
      # caseの条件がおおいがこれ以上ふることは考えられないのとこれ以上メソッド分割をしないほうが理解しやすいので分割をしない

      # rubocop:disable Metrics/AbcSize
      def build_methods
        AllMethodParams.all.map do |spec|
          case spec[:type]
          when :basic
            build_basic_method_hash(spec[:name], spec[:return_type], spec[:options])
          when :parametered
            build_parametered_method_hash(spec[:name], spec[:return_type], spec[:parameters], spec[:options])
          when :block
            build_block_method_hash(spec[:name], spec[:return_type], spec[:parameters], spec[:block], spec[:options])
          else
            raise "Unknown spec type: #{spec[:type]}"
          end
        end
      end
      # rubocop:enable Metrics/AbcSize

      private

      def build_basic_method_hash(name, return_type, options = {})
        {
          name: name,
          method_type: options[:method_type] || 'instance',
          visibility: options[:visibility] || 'public',
          parameters: options[:parameters] || [],
          return_type: return_type,
          overloads: options[:overloads] || [],
          block: nil
        }
      end

      def build_parametered_method_hash(name, return_type, parameters, options = {})
        {
          name: name,
          method_type: options[:method_type] || 'instance',
          visibility: options[:visibility] || 'public',
          parameters: parameters,
          return_type: return_type,
          overloads: options[:overloads] || [],
          block: nil
        }
      end

      def build_block_method_hash(name, return_type, parameters, block_info, options = {})
        {
          name: name,
          method_type: options[:method_type] || 'instance',
          visibility: options[:visibility] || 'public',
          parameters: parameters,
          return_type: return_type,
          overloads: options[:overloads] || [],
          block: block_info
        }
      end
    end
  end
end
