# frozen_string_literal: true

require_relative 'rbs_parser'
require_relative 'formatter'

class RBSToDiagram
  def self.execute(input_file, output_file = nil)
    new(input_file, output_file).execute
  end

  private_class_method :new

  def initialize(input_file, output_file)
    @input_file = input_file
    @output_file = add_timestamp_to_filename(output_file || default_output_file_path)
  end

  def execute
    FileUtils.mkdir_p(File.dirname(output_file))

    parser_result = RBSParser.parse(input_file)
    output = Formatter.format(parser_result)

    File.write(output_file, output)
  end

  private

  attr_reader :input_file, :output_file

  def default_output_file_path
    base_name = File.basename(input_file, '.rbs')
    File.join('output', "#{base_name}.json")
  end

  def add_timestamp_to_filename(file_path)
    timestamp = Time.now.strftime('%Y%m%d%H%M')
    dir = File.dirname(file_path)
    basename = File.basename(file_path, '.*')
    ext = File.extname(file_path)

    File.join(dir, "#{basename}_#{timestamp}#{ext}")
  end
end
