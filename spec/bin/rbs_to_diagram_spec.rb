# frozen_string_literal: true

require 'open3'
require 'fileutils'
require 'json'

ALLOWED_TYPES = %w[class module].freeze

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

  describe 'JSON形式でのパース' do
    it 'デモ用RBSファイルをJSON形式でパースできる' do
      output_file = File.join(test_output_dir, 'demo_output.json')
      stdout, stderr, status = Open3.capture3("ruby #{bin_script} #{demo_input_file} #{output_file}")

      unless status.success?
        puts "STDOUT: #{stdout}"
        puts "STDERR: #{stderr}"
        puts "Exit status: #{status.exitstatus}"
      end

      expect(status.success?).to be(true), 'binスクリプトの実行が失敗しました'
      expect(stdout).not_to be_empty, '標準出力が空です'
    end

    it 'JSON形式で正しいファイルが生成される' do
      output_file = File.join(test_output_dir, 'demo_output.json')
      _stdout, _stderr, status = Open3.capture3("ruby #{bin_script} #{demo_input_file} #{output_file}")

      expect(status.success?).to be(true)

      generated_files = Dir.glob(File.join(test_output_dir, 'demo_output_*.json'))
      expect(generated_files).not_to be_empty, 'JSON形式の出力ファイルが生成されませんでした'

      generated_file = generated_files.first
      expect(File.size(generated_file)).to be > 0, '生成されたファイルが空です'
    end

    it 'JSON形式の内容が正しく含まれている' do
      output_file = File.join(test_output_dir, 'demo_content.json')
      _stdout, _stderr, status = Open3.capture3("ruby #{bin_script} #{demo_input_file} #{output_file}")

      expect(status.success?).to be(true)
      generated_files = Dir.glob(File.join(test_output_dir, 'demo_content_*.json'))
      content = File.read(generated_files.first)

      expect { JSON.parse(content) }.not_to raise_error, '生成されたJSONファイルが不正です'
      expect(content).to include('BlogApp'), 'ネームスペース情報が含まれていません'
      expect(content).to include('BaseModel'), '基底クラス情報が含まれていません'
      expect(content).to include('User'), 'Userクラス情報が含まれていません'
    end
  end

  describe 'Mermaid形式でのパース' do
    it 'デモ用RBSファイルをMermaid形式でパースできる' do
      output_file = File.join(test_output_dir, 'demo_output.mermaid')
      stdout, stderr, status = Open3.capture3("ruby #{bin_script} #{demo_input_file} #{output_file}")

      unless status.success?
        puts "STDOUT: #{stdout}"
        puts "STDERR: #{stderr}"
        puts "Exit status: #{status.exitstatus}"
      end

      expect(status.success?).to be(true), 'binスクリプトの実行が失敗しました'
      expect(stdout).not_to be_empty, '標準出力が空です'
    end

    it 'Mermaid形式で正しいファイルが生成される' do
      output_file = File.join(test_output_dir, 'demo_output.mermaid')
      _stdout, _stderr, status = Open3.capture3("ruby #{bin_script} #{demo_input_file} #{output_file}")

      expect(status.success?).to be(true)

      generated_files = Dir.glob(File.join(test_output_dir, 'demo_output_*.mermaid'))
      expect(generated_files).not_to be_empty, 'Mermaid形式の出力ファイルが生成されませんでした'

      generated_file = generated_files.first
      expect(File.size(generated_file)).to be > 0, '生成されたファイルが空です'
    end

    it 'Mermaid形式の内容が正しく含まれている' do
      output_file = File.join(test_output_dir, 'demo_content.mermaid')
      _stdout, _stderr, status = Open3.capture3("ruby #{bin_script} #{demo_input_file} #{output_file}")

      expect(status.success?).to be(true)
      generated_files = Dir.glob(File.join(test_output_dir, 'demo_content_*.mermaid'))
      content = File.read(generated_files.first)

      expect(content).to include('BlogApp_Models'), 'ネームスペース情報が含まれていません'
    end
  end

  describe 'デモファイルの特徴的な要素の確認' do
    it 'JSON出力にブログアプリケーションの主要な構造が含まれている' do
      output_file = File.join(test_output_dir, 'demo_structure.json')
      _stdout, _stderr, status = Open3.capture3("ruby #{bin_script} #{demo_input_file} #{output_file}")

      expect(status.success?).to be(true)
      generated_files = Dir.glob(File.join(test_output_dir, 'demo_structure_*.json'))
      content = File.read(generated_files.first)
      parsed_json = JSON.parse(content)

      structure_names = parsed_json['structure'].map { |item| item['name'] }
      expect(structure_names).to include('BlogApp', 'BlogApp::Models::BaseModel', 'BlogApp::Models::User',
                                         'BlogApp::Models::Post', 'BlogApp::Models::Comment', 'BlogApp::Models::Tag')
      expect(structure_names).to include('Authenticatable', 'Trackable', 'Observable')
      expect(structure_names).to include('BlogApp::Services::PostService', 'BlogApp::Services::NotificationService')
      expect(structure_names).to include('Logger', 'Configuration')
    end

    it 'Mermaid出力にクラス関係図が含まれている' do
      output_file = File.join(test_output_dir, 'demo_diagram.mermaid')
      _stdout, _stderr, status = Open3.capture3("ruby #{bin_script} #{demo_input_file} #{output_file}")

      expect(status.success?).to be(true)
      generated_files = Dir.glob(File.join(test_output_dir, 'demo_diagram_*.mermaid'))
      content = File.read(generated_files.first)

      expect(content).to include('namespace BlogApp_Models'), 'Modelsネームスペースが含まれていません'
      expect(content).to include('namespace BlogApp_Services'), 'Servicesネームスペースが含まれていません'
      expect(content).to include('BaseModel <|-- BlogApp_Models_User'), '継承関係が含まれていません'
      expect(content).to include('-->'), 'アソシエーション関係が含まれていません'
    end
  end

  describe 'パース結果とcompareファイルの一致確認' do
    let(:compare_json_file) { 'spec/fixtures/demo/compare.json' }
    let(:compare_mermaid_file) { 'spec/fixtures/demo/compare.mermaid' }

    it 'JSON形式のパース結果がcompare_demo.jsonと一致する' do
      output_file = File.join(test_output_dir, 'demo_compare.json')
      _stdout, _stderr, status = Open3.capture3("ruby #{bin_script} #{demo_input_file} #{output_file}")

      expect(status.success?).to be(true), 'binスクリプトの実行が失敗しました'

      generated_files = Dir.glob(File.join(test_output_dir, 'demo_compare_*.json'))
      expect(generated_files).not_to be_empty, 'JSONファイルが生成されませんでした'

      actual_content = File.read(generated_files.first)
      expected_content = File.read(compare_json_file)

      actual_json = JSON.parse(actual_content)
      expected_json = JSON.parse(expected_content)

      expect(actual_json).to eq(expected_json), 'パース結果がcompare_demo.jsonと一致しません'
    end

    it 'Mermaid形式のパース結果がcompare_demo.mermaidと一致する' do
      output_file = File.join(test_output_dir, 'demo_compare.mermaid')
      _stdout, _stderr, status = Open3.capture3("ruby #{bin_script} #{demo_input_file} #{output_file}")

      expect(status.success?).to be(true), 'binスクリプトの実行が失敗しました'

      generated_files = Dir.glob(File.join(test_output_dir, 'demo_compare_*.mermaid'))
      expect(generated_files).not_to be_empty, 'Mermaidファイルが生成されませんでした'

      actual_content = File.read(generated_files.first).strip
      expected_content = File.read(compare_mermaid_file).strip

      expect(actual_content).to eq(expected_content), 'パース結果がcompare_demo.mermaidと一致しません'
    end

    it 'JSON出力の基本構造が正しい' do
      json_output_file = File.join(test_output_dir, 'demo_structure_test.json')
      _stdout, _stderr, status = Open3.capture3("ruby #{bin_script} #{demo_input_file} #{json_output_file}")

      expect(status.success?).to be(true)
      json_files = Dir.glob(File.join(test_output_dir, 'demo_structure_test_*.json'))
      json_content = JSON.parse(File.read(json_files.first))

      expect(json_content).to have_key('structure')
      expect(json_content['structure']).to be_an(Array)
      expect(json_content['structure'].length).to be > 10, '十分な数のクラス・モジュールが含まれていません'
    end

    it 'JSON出力の各要素が正しい構造を持つ' do
      json_output_file = File.join(test_output_dir, 'demo_element_test.json')
      _stdout, _stderr, status = Open3.capture3("ruby #{bin_script} #{demo_input_file} #{json_output_file}")

      expect(status.success?).to be(true)
      json_files = Dir.glob(File.join(test_output_dir, 'demo_element_test_*.json'))
      json_content = JSON.parse(File.read(json_files.first))

      json_content['structure'].each do |item|
        expect(item).to have_key('type')
        expect(item).to have_key('name')
        expect(item).to have_key('methods')
        expect(item['type']).to(satisfy { |v| ALLOWED_TYPES.include?(v) })
      end
    end
  end
end
