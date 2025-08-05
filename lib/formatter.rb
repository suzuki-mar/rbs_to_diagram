# frozen_string_literal: true

require_relative 'formatter/json'
require_relative 'formatter/mermaidjs'

class Formatter
  def self.format(parser_result, format_type = :json)
    new.format(parser_result, format_type)
  end

  def initialize
    @json_formatter = Formatter::JSON.new
    @mermaidjs_formatter = Formatter::MermaidJS.new
  end

  def format(parser_result, format_type = :json)
    case format_type
    when :json
      json_formatter.format(parser_result)
    when :mermaidjs
      mermaidjs_formatter.format(parser_result)
    else
      raise ArgumentError, "Unsupported format type: #{format_type}"
    end
  end

  private

  attr_reader :json_formatter, :mermaidjs_formatter
end
