module Remap
  module Catchable
    def catch_ignored(&block)
      catch(to_id(:ignored), &block)
    end

    def catch_fatal(&block)
      catch(to_id(:fatal), &block)
    end

    def to_id(value)
      [value, self.class.name&.downcase || :unknown].join("::")
    end
  end
end
