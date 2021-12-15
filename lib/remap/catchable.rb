# frozen_string_literal: true

module Remap
  module Catchable
    # @yieldparam id [Symbol]
    # @yieldreturn [T]
    #
    # @return [T]
    def catch_ignored(&block)
      catch(to_id(:ignored), &block)
    end

    # @yieldparam id [Symbol]
    # @yieldreturn [T]
    #
    # @return [T]
    def catch_fatal(&block)
      catch(to_id(:fatal), &block)
    end

    private

    def to_id(value)
      [value, self.class.name&.downcase || :unknown].join("::")
    end
  end
end
