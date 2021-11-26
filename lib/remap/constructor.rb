# frozen_string_literal: true

module Remap
  class Constructor < Dry::Interface
    attribute :method, Symbol, default: :new
    attribute :target, Types::Any.constrained(not_eql: Nothing)

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

    def id
      attributes.fetch(:method)
    end

    def to_proc
      method(:call).to_proc
    end
  end
end
