describe Remap::Path::Output do
  describe "#call" do
    let(:path) { described_class.call([all!, index!(1), :key]) }
    let(:value) do
      [
        ["skip", { key: "value1" }],
        ["skip", { key: "value2" }]
      ]
    end
    let(:state) { state!(value) }

    subject { path.call(state) }

    it { is_expected.to contain(["value1", "value2"]) }
  end
end
