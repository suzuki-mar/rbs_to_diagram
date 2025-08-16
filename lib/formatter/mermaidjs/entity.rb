# frozen_string_literal: true

require_relative 'entity/base'
require_relative 'entity/class'
require_relative 'entity/module'
require_relative 'entity/module_as_class'
require_relative 'entity/namespace'
require_relative 'entity/empty_namespace'
require_relative 'entity/namespace_class'

class Formatter
  class MermaidJS
    module Entity
      def self.create_for_node(node, method_converter, has_namespaces: false)
        if node.type == :class
          methods = method_converter.call(node.methods_ordered_by_visibility_and_type, :class)
          Class.new(name: node.name, methods: methods)
        elsif has_namespaces
          # ネームスペースコンテキストでは通常のモジュールをクラスとして表示（staticにしない）
          methods = method_converter.call(node.methods_ordered_by_visibility_and_type, :class)
          ModuleAsClass.new(name: node.name, methods: methods)
        else
          methods = method_converter.call(node.methods_ordered_by_visibility_and_type, :module)
          Module.new(name: node.name, methods: methods)
        end
      end
    end
  end
end
