# frozen_string_literal: true

module Remap
  class Notice
    using Extensions::Hash
    using State::Extension

    class Error < Remap::Error
      extend Dry::Initializer

      delegate_missing_to :notice
      delegate :inspect, :to_s, to: :notice
      option :notice, type: Types.Instance(Notice)
    end
  end
end
