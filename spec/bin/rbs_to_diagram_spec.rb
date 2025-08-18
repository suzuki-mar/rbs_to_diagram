# frozen_string_literal: true

require 'open3'
require 'fileutils'
require 'json'

ALLOWED_TYPES = %w[class module].freeze

def run_rbs_to_diagram_and_read(bin_script:, input_file:, output_file:, test_output_dir:, glob_pattern:)
  full_output_path = File.join(test_output_dir, output_file)
  _stdout, _stderr, status = Open3.capture3("ruby #{bin_script} #{input_file} #{full_output_path}")
  generated_files = Dir.glob(glob_pattern)
  file_path = generated_files.first
  content = File.read(file_path) if file_path
  {
    status: status,
    file_path: file_path,
    content: content,
    output_file: output_file
  }
end

RSpec.shared_examples '出力内容の検証' do |result, expected_includes|
  it '出力内容に期待値が含まれている' do
    content = result[:content]
    expected_includes.each do |expected|
      expect(content).to include(expected)
    end
  end
end

describe 'bin/rbs_to_diagram script - デモ用RBSファイルのパース' do
  let(:bin_script) { File.expand_path('../../bin/rbs_to_diagram', __dir__) }
  let(:demo_input_file) { 'spec/fixtures/demo/target.rbs' }
  let(:test_output_dir) { 'spec/tmp_output' }

  before do
    FileUtils.mkdir_p(test_output_dir)
  end

  after do
    FileUtils.rm_rf(test_output_dir)
  end

  context 'JSON出力' do
    result = run_rbs_to_diagram_and_read(
      bin_script: File.expand_path('../../bin/rbs_to_diagram', __dir__),
      input_file: 'spec/fixtures/demo/target.rbs',
      output_file: 'demo_structure.json',
      test_output_dir: 'spec/tmp_output',
      glob_pattern: File.join('spec/tmp_output', 'demo_structure_*.json')
    )
    expected_includes = %w[Logger Configuration BlogApp BaseModel User Post Comment Tag
                           Authenticatable Trackable Observable PostService NotificationService]
    it_behaves_like '出力内容の検証', result, expected_includes
  end

  context 'Mermaid出力' do
    result = run_rbs_to_diagram_and_read(
      bin_script: File.expand_path('../../bin/rbs_to_diagram', __dir__),
      input_file: 'spec/fixtures/demo/target.rbs',
      output_file: 'demo_diagram.mermaid',
      test_output_dir: 'spec/tmp_output',
      glob_pattern: File.join('spec/tmp_output', 'demo_diagram_*.mermaid')
    )
    expected_includes = ['namespace BlogApp_Models', 'namespace BlogApp_Services',
                         'BaseModel <|-- BlogApp_Models_User', '-->']
    it_behaves_like '出力内容の検証', result, expected_includes
  end
end
