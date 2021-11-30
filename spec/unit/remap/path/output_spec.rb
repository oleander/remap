# frozen_string_literal: true

describe Remap::Path::Output do
  describe "#call" do
    subject { path.call(state) }

    let(:path) { described_class.call([:a, :b]) }
    let(:value) { string! }
    let(:state) { state!(value) }

    it { is_expected.to contain({ a: { b: value } }) }
  end
end
