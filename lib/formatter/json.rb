# frozen_string_literal: true

require 'json'

# JSONフォーマッター（コントロールオブジェクト）
class Formatter
  class JSON
    def format(parser_result)
      structure = build_structure(parser_result)

      ::JSON.pretty_generate({
                               file_path: parser_result.file_info[:file_path],
                               structure: structure
                             })
    end

    private

    def build_structure(parser_result)
      # Resultクラスから既に詳細構造が返されるので、それらを結合するだけ
      parser_result.class_definitions + parser_result.module_definitions
    end
  end
end
