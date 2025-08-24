# frozen_string_literal: true

require_relative 'base'
require_relative '../entity_param'

module Formatter
  class Diagram::PlantUML
    module Entity
      class InnerClassEntity < Base
        extend Forwardable

        private attr_reader :param

        def_delegators :@param, :package_name, :methods, :method_classes, :syntax, :indentation

        def initialize(param)
          super(name: param.name, type: :inner_class, syntax: param.syntax, indentation: param.indentation)
          @param = param
        end

        def render
          indent_str = indentation.to_s
          lines = [] # : Array[String]
          lines << "#{indent_str}package #{package_name} {"
          lines << "#{indent_str}    class #{name} {"
          lines.concat(methods.map { |method| "    #{method}" })
          lines.concat(method_classes.map { |mc| "    #{mc.to_method_signature}" })
          lines << "#{indent_str}    }"
          lines << "#{indent_str}}"
          lines
        end
      end
    end
  end
end
