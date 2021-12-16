# frozen_string_literal: true

module Remap
  # @api private
  module Catchable
    using State::Extension

    # @param state [State]
    #
    # @yieldparam state [State]
    # @yieldparam id [Symbol, String]
    # @yieldreturn [State<T>]
    #
    # @return [State<T>]
    def catch_ignored(state, &block)
      id = to_id(:ignored)

      catch(id) do
        block[state.set(id: id), id: id].remove_id
      end
    end

    # @param state [State]
    # @param backtrace [Array<String>]
    #
    # @yieldparam state [State]
    # @yieldparam id [Symbol, String]
    # @yieldreturn [State<T>]
    #
    # @return [State<T>]
    # @raise [Failure::Error]
    def catch_fatal(state, backtrace, &block)
      id = to_id(:fatal)

      failure = catch(id) do
        return block[state.set(fatal_id: id), fatal_id: id].remove_fatal_id
      end

      raise failure.exception(backtrace)
    end

    private

    def to_id(value)
      [value, self.class.name&.downcase || :unknown].join("::")
    end
  end
end
