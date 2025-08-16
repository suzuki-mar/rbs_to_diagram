# frozen_string_literal: true

require 'fileutils'
require 'rspec-parameterized'
require_relative '../lib/rbs_to_diagram'

describe 'RBSファイルをパースして解析結果のファイル出力をする' do
  using RSpec::Parameterized::TableSyntax

  where(:target_file, :output_file, :compare_file) do
    [

      [
        'spec/fixtures/target_method_comprehensive_class.rbs',
        'spec/output/target_method_comprehensive_class.mermaid',
        'spec/fixtures/compare_method_comprehensive_class.mermaid'
      ],
      [
        'spec/fixtures/target_method_comprehensive_class.rbs',
        'spec/output/target_method_comprehensive_class.json',
        'spec/fixtures/compare_method_comprehensive_class.json'
      ],
      [
        'spec/fixtures/target_related_classes.rbs',
        'spec/output/target_related_classes.mermaid',
        'spec/fixtures/compare_related_classes.mermaid'
      ],
      [
        'spec/fixtures/target_module.rbs',
        'spec/output/target_module.mermaid',
        'spec/fixtures/compare_module.mermaid'
      ],
      [
        'spec/fixtures/target_namespace.rbs',
        'spec/output/target_namespace.json',
        'spec/fixtures/compare_namespace.json'
      ],
      [
        'spec/fixtures/target_namespace.rbs',
        'spec/output/target_namespace.mermaid',
        'spec/fixtures/compare_namespace.mermaid'
      ]
    ]
  end

  with_them do
    subject { RBSToDiagram.execute(target_file, output_file) }

    let(:parsed_time) { Time.new(2025, 7, 25, 14, 53) }

    let(:expected_output_file) do
      base_name = File.basename(target_file, '.rbs')
      timestamp = parsed_time.strftime('%Y%m%d%H%M')
      extension = File.extname(output_file)
      File.join('spec/output', "#{base_name}_#{timestamp}#{extension}")
    end

    before do
      allow(Time).to receive(:now).and_return(parsed_time)
    end

    after do
      FileUtils.rm_f(expected_output_file)
    end

    it '期待される出力と一致する' do
      subject
      expect(File.exist?(expected_output_file)).to be true
      actual_output = File.read(expected_output_file)
      expected_output = File.read(compare_file)
      expect(actual_output).to eq(expected_output)
    end
  end
end
