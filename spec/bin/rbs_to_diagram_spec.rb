# frozen_string_literal: true

require 'open3'
require 'fileutils'
require 'rspec-parameterized'

describe 'bin/rbs_to_diagram script' do
  using RSpec::Parameterized::TableSyntax

  let(:bin_script) { File.expand_path('../../bin/rbs_to_diagram', __dir__) }
  let(:test_input_file) { 'spec/fixtures/target_method_comprehensive_class.rbs' }
  let(:test_output_dir) { 'spec/tmp_output' }

  before do
    FileUtils.mkdir_p(test_output_dir)
  end

  after do
    FileUtils.rm_rf(test_output_dir)
  end

  where(:format_type, :extension) do
    [
      ['JSON', 'json'],
      ['Mermaid.js', 'mermaid']
    ]
  end

  with_them do
    it "binスクリプトが正常に実行され、#{params[:format_type]}形式でファイルが生成される" do
      output_file = File.join(test_output_dir, "test_output.#{extension}")
      stdout, stderr, status = Open3.capture3("ruby #{bin_script} #{test_input_file} #{output_file}")

      # デバッグ情報を出力
      unless status.success?
        puts "STDOUT: #{stdout}"
        puts "STDERR: #{stderr}"
        puts "Exit status: #{status.exitstatus}"
      end

      expect(status.success?).to be true
      expect(stdout).not_to be_empty

      # ファイルが生成されていることを確認
      generated_files = Dir.glob(File.join(test_output_dir, "test_output_*.#{extension}"))
      expect(generated_files).not_to be_empty
    end
  end
end
