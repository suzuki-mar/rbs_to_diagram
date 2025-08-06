# frozen_string_literal: true

require_relative 'rbs_parser/signature_analyzer'
require_relative 'result'

class RBSParser
  def self.parse(file_paths)
    new(file_paths).parse
  end

  private_class_method :new

  def initialize(file_paths)
    @file_paths = file_paths.is_a?(Array) ? file_paths : [file_paths]
  end

  def parse
    all_definitions = [] # : Array[Result::definition_hash]

    file_paths.each do |file_path|
      next unless validate_file_exists?(file_path)

      content = load_file_content(file_path)
      declarations = RBSParser::SignatureAnalyzer.analyze_content(content, file_path)
      definitions = RBSParser::SignatureAnalyzer.extract_definitions(declarations)
      all_definitions.concat(definitions)
    end

    Result.new(definitions: all_definitions)
  end

  private

  attr_reader :file_paths

  def validate_file_exists?(file_path)
    File.exist?(file_path)
  end

  def load_file_content(file_path)
    File.read(file_path, encoding: 'UTF-8')
  end
end
