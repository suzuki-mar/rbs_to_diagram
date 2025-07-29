# frozen_string_literal: true

require_relative 'formatter/json'

# フォーマット処理をまとめるクラス
class Formatter
  def self.format(parser_result)
    new.format(parser_result)
  end

  def initialize
    @json_formatter = Formatter::JSON.new
  end

  def format(parser_result)
    @json_formatter.format(parser_result)
  end
end
