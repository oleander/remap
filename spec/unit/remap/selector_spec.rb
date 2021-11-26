# frozen_string_literal: true

describe Remap::Selector do
  let(:type) { Types.Array(described_class) }
  let(:keys) { type[%i[a b c]] }
  let(:state) { state!({ a: { b: { X: 1 } } }) }

  specify do
  end
end
