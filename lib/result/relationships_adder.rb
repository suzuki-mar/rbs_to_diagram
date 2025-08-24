# frozen_string_literal: true

require_relative 'node_entity/relationship_node'

class Result
  class RelationshipsAdder
    def self.add_inheritance(node)
      new(node).add_inheritance
    end

    def self.add_delegation(node)
      new(node).add_delegation
    end

    def self.add_include(node)
      new(node).add_include
    end

    def self.add_extend(node)
      new(node).add_extend
    end

    def initialize(node)
      @node = node
    end

    private_class_method :new

    private

    attr_reader :node

    # newを外部クラスから禁止しているので実質privateメソッド
    public

    def add_inheritance
      # Moduleノードには継承関係がないため、ClassまたはInnerClassのみ処理
      return unless node.is_a?(Result::NodeEntity::Class) || node.is_a?(Result::NodeEntity::InnerClass)

      superclass = node.superclass
      return unless superclass

      inheritance_node = Result::NodeEntity::Relationship.new(
        name: "#{superclass}_to_#{node.name}",
        relationship_type: :inheritance,
        from: superclass,
        to: node.name
      )
      node.add_relationship(inheritance_node)
    end

    def add_delegation
      # Moduleノードには委譲関係がないため、ClassまたはInnerClassのみ処理
      return unless node.is_a?(Result::NodeEntity::Class) || node.is_a?(Result::NodeEntity::InnerClass)

      node.methods.each do |method|
        next unless method.parameters.empty?
        next if builtin_class?(method.return_type)

        node.add_relationship(
          build_relationship_node_for_delegate(method)
        )
      end
    end

    def add_include
      node.includes.each do |included_module|
        include_node = Result::NodeEntity::Relationship.new(
          name: "#{included_module}_to_#{node.name}",
          relationship_type: :include,
          from: included_module,
          to: node.name
        )
        node.add_relationship(include_node)
      end
    end

    def add_extend
      node.extends.each do |extended_module|
        extend_node = Result::NodeEntity::Relationship.new(
          name: "#{extended_module}_to_#{node.name}",
          relationship_type: :extend,
          from: extended_module,
          to: node.name
        )
        node.add_relationship(extend_node)
      end
    end

    def builtin_class?(type_name)
      return true if type_name.nil? || type_name == ''

      builtin_literals = %w[
        String Integer Float Array Hash Time IO bool void nil
      ]
      return true if builtin_literals.include?(type_name)

      regex_patterns = [
        /\AArray\[/,
        /\AHash\[/,
        /\|/,
        /\A\w+\[/
      ]
      return true if regex_patterns.any? { |r| type_name.match?(r) }

      false
    end

    # add_inheritanceとかのこのクラスにおけるpublicメソッドないからしか呼ばれないもの
    private

    def build_relationship_node_for_delegate(method)
      Result::NodeEntity::Relationship.new(
        name: "#{node.name}_to_#{method.return_type}",
        relationship_type: :delegation,
        from: node.name,
        to: method.return_type
      )
    end
  end
end
