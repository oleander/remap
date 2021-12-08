# frozen_string_literal: true

module Remap
  module State
    Schema = Dry::Schema.define do
      required(:input)

      required(:mapper).filled(Remap::Types::Mapper)
      required(:notices).array(Types.Instance(Notice))
      required(:options).value(:hash)
      required(:path).array(Types::Key)

      optional(:index).filled(:integer)
      optional(:element).filled
      optional(:key).filled

      optional(:scope)
      optional(:value)
    end
  end
end
