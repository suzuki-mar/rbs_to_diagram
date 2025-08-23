# frozen_string_literal: true

require_relative '../node'

class Result
  module NodeEntity
    class Relationship < Node
      # @relationship_type: Symbol
      # @from: String
      # @to: String
      attr_reader :relationship_type, :from, :to

      def initialize(name:, relationship_type:, from:, to:)
        super(name: name, type: :relationship)
        @relationship_type = relationship_type # :inheritance or :delegation
        @from = from
        @to = to
      end

      def inheritance?
        relationship_type == :inheritance
      end

      def delegation?
        relationship_type == :delegation
      end
    end
  end
end
