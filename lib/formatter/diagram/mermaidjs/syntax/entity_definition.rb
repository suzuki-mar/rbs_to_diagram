# frozen_string_literal: true

module Formatter
  class Diagram
    class MermaidJS
      class Syntax
        class EntityDefinition
          private attr_reader :indentation

          def initialize(indentation:)
            @indentation = indentation
          end

          def class(class_name, methods)
            safe_name = class_name.gsub(/\?$/, '')
            def_indent = indentation.to_s
            # 通常クラスとnamespace内クラスのメソッドは4スペース追加（method_signaturesの4スペース + 4スペース = 8スペース）
            body_indent = ' ' * 4
            lines = [] # : Array[String]
            lines << "#{def_indent}class #{safe_name} {"
            methods.each do |m|
              lines << "#{body_indent}#{m}"
            end
            lines << "#{def_indent}}"
            lines
          end

          def module(module_name, methods)
            safe_name = module_name.gsub(/\?$/, '')
            def_indent = '' # モジュールは常にインデントなし
            body_indent = '' # モジュールのメソッドはインデントなし（method_signaturesで既に付与済み）
            lines = [] # : Array[String]
            lines << "#{def_indent}class #{safe_name} {"
            methods.each do |m|
              lines << "#{body_indent}#{m}"
            end
            lines << "#{def_indent}}"
            lines
          end

          def namespace(namespace_name, content)
            safe_name = namespace_name.gsub(/\?$/, '')
            def_indent = '' # namespaceは常にインデントなし
            body_indent = ' ' * 4 # 常に4スペース固定
            lines = [] # : Array[String]
            lines << "#{def_indent}namespace #{safe_name} {"
            content.each do |c|
              if c.is_a?(Array)
                c.each { |line| lines << (line.empty? ? line : body_indent + line) }
              else
                lines << (c.empty? ? c : body_indent + c)
              end
            end
            lines << "#{def_indent}}"
            lines
          end
        end
      end
    end
  end
end
