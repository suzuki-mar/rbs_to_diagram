# frozen_string_literal: true

require 'fileutils'
require_relative 'rbs_parser'
require_relative 'formatter'

class RBSToDiagram
  def self.execute(input_paths, output_file = nil)
    new(input_paths, output_file).execute
  end

  private_class_method :new

  def initialize(input_paths, output_file)
    @input_paths = input_paths.is_a?(Array) ? input_paths : [input_paths]
    @output_file = add_timestamp_to_filename(output_file || default_output_file_path)
  end

  def execute
    FileUtils.mkdir_p(File.dirname(output_file))

    rbs_files = collect_rbs_files(input_paths)
    parser_result = RBSParser.parse(rbs_files)
    format_type = determine_format_type(output_file)
    output = Formatter.format(parser_result, format_type)

    File.write(output_file, output)

    { output_file: output_file, format_type: format_type, content: output }
  end

  private

  attr_reader :input_paths, :output_file

  def collect_rbs_files(paths)
    rbs_files = [] # : Array[String]

    paths.each do |path|
      if File.directory?(path)
        rbs_files.concat(Dir.glob(File.join(path, '**', '*.rbs')))
      elsif File.file?(path) && path.end_with?('.rbs')
        rbs_files << path
      end
    end

    rbs_files.uniq
  end

  def default_output_file_path
    base_name = input_paths.size == 1 ? File.basename(input_paths.first, '.rbs') : 'multiple_classes'
    File.join('output', "#{base_name}.json")
  end

  def add_timestamp_to_filename(file_path)
    timestamp = Time.now.strftime('%Y%m%d%H%M')
    dir = File.dirname(file_path)
    basename = File.basename(file_path, '.*')
    ext = File.extname(file_path)

    File.join(dir, "#{basename}_#{timestamp}#{ext}")
  end

  def determine_format_type(file_path)
    case File.extname(file_path)
    when '.mermaid'
      :mermaidjs
    else
      :json # デフォルトはJSON（.jsonや未知の拡張子）
    end
  end
end
