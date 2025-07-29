# frozen_string_literal: true

# RBS解析結果を集約するデータクラス
class RBSParser
  class Result
    attr_reader :definitions, :file_info, :parsed_at

    def initialize(definitions:, file_path:)
      @definitions = definitions
      @file_info = { file_path: file_path }
      @parsed_at = Time.now
    end

    def class_definitions
      @definitions.select { |definition| definition[:type] == :class }
                  .map { |definition| build_detailed_class_structure(definition) }
    end

    def module_definitions
      @definitions.select { |definition| definition[:type] == :module }
                  .map { |definition| build_detailed_module_structure(definition) }
    end

    private

    def build_detailed_class_structure(class_def)
      {
        type: 'class',
        name: class_def[:name],
        superclass: nil, # TODO: 継承関係の実装
        methods: class_def[:methods],
        includes: [], # TODO: includeの実装
        extends: [] # TODO: extendの実装
      }
    end

    def build_detailed_module_structure(module_def)
      {
        type: 'module',
        name: module_def[:name],
        methods: module_def[:methods],
        includes: [], # TODO: includeの実装
        extends: [] # TODO: extendの実装
      }
    end
  end
end
