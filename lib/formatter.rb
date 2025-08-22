# frozen_string_literal: true

require_relative 'formatter/json'
require_relative 'formatter/diagram'

module Formatter
  module_function

  def format(parser_result, format_type: :json)
    case format_type
    when :json
      Formatter::Json.format(parser_result)
    when :mermaidjs, :plantuml
      Formatter::Diagram.new(format_type).format(parser_result)
    else
      raise ArgumentError, "Unsupported format type: #{format_type}"
    end
  end
end
