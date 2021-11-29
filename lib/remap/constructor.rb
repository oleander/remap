# frozen_string_literal: true

module Remap
  class Constructor < Dry::Interface
    attribute :target, Types::Any, not_eql: Nothing
    attribute :method, Symbol, default: :new

    # Ensures {#target} responds to {#method}
    # Returns an error state unless above is true
    #
    # @param state [State]
    #
    # @return [State]
    def call(state)
      state.tap do
        unless target.respond_to?(id)
          raise ArgumentError, "Target [#{target}] does not respond to [#{id}]"
        end
      end
    end

    # @return [Proc]
    def to_proc
      method(:call).to_proc
    end

    private

    # @return [Symbol]
    def id
      attributes.fetch(:method)
    end
  end
end
