# frozen_string_literal: true

require_relative 'rbs_parser/signature_analyzer'
require_relative 'result'

class RBSParser
  def self.parse(file_path)
    new(file_path).parse
  end

  private_class_method :new

  def initialize(file_path)
    @file_path = file_path
  end

  def parse
    validate_file_exists
    content = load_file_content
    declarations = RBSParser::SignatureAnalyzer.analyze_content(content, file_path)
    definitions = RBSParser::SignatureAnalyzer.extract_definitions(declarations)

    Result.new(
      definitions: definitions,
      file_path: file_path
    )
  end

  private

  attr_reader :file_path

  def validate_file_exists
    raise "File not found: #{file_path}" unless File.exist?(file_path)
  end

  def load_file_content
    File.read(file_path, encoding: 'UTF-8')
  end
end
