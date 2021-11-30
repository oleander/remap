describe Remap::Path::Output do
  describe "#call" do
    let(:path) { described_class.call([:a, :b]) }
    let(:value) { string! }
    let(:state) { state!(value) }

    subject { path.call(state) }

    it { is_expected.to contain({ a: { b: value } }) }
  end
end
