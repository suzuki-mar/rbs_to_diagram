# frozen_string_literal: true

require_relative '../lib/rbs_to_diagram'

class CLIHelper
  DEMO_INPUT_DIR = 'source/demo'
  SOURCE_DIR = 'source'

  def self.validate_demo_directory
    raise "Demo directory '#{DEMO_INPUT_DIR}' not found" unless Dir.exist?(DEMO_INPUT_DIR)

    rbs_files = Dir.glob(File.join(DEMO_INPUT_DIR, '*.rbs'))
    raise "No RBS files found in '#{DEMO_INPUT_DIR}' directory" if rbs_files.empty?

    rbs_files
  end

  def self.validate_source_directory
    raise "Source directory '#{SOURCE_DIR}' not found" unless Dir.exist?(SOURCE_DIR)

    rbs_files = Dir.glob(File.join(SOURCE_DIR, '*.rbs'))
    raise "No RBS files found in '#{SOURCE_DIR}' directory" if rbs_files.empty?

    rbs_files
  end

  def self.validate_input_file(input_file)
    raise "Input file '#{input_file}' not found" unless File.exist?(input_file)
  end

  def self.demo_header(file_count)
    [
      '🚀 Running RBS to Diagram Demo',
      '=' * 50,
      "Input directory: #{DEMO_INPUT_DIR}",
      "Processing #{file_count} RBS files",
      ''
    ].join("\n")
  end

  def self.demo_generation
    '📊 Generating Mermaid.js format...'
  end

  def self.demo_completion(output_file)
    "\n🎉 Demo completed! Check the generated file: #{output_file}"
  end

  def self.source_processing(file_count)
    "Processing #{file_count} RBS files from #{SOURCE_DIR}/"
  end

  def self.generation_success(output_file)
    "✓ Generated: #{output_file}"
  end

  def self.generation_error(input_file, error_message)
    "✗ Error processing #{input_file}: #{error_message}"
  end

  def self.single_file_success(output_file)
    "Successfully generated diagram: #{output_file}"
  end

  def self.mermaid_viewer_info(result)
    [
      "\n#{'=' * 50}",
      'Mermaid.js Viewer URL:',
      'https://mermaid.live/edit',
      "\nCopy and paste the following Mermaid.js code:",
      '-' * 50,
      result[:content],
      '-' * 50
    ].join("\n")
  end

  def self.create_help_text(program_name)
    <<~HELP
      Examples:
        #{program_name}                                    # Process all files in source/
        #{program_name} --demo                             # Run demo
        #{program_name} source/simple_class.rbs            # Process single file
        #{program_name} source/simple_class.rbs output.json # Process with custom output
    HELP
  end
end
