# frozen_string_literal: true

describe Remap::Path::Input do
  describe "#call" do
    subject { path.call(state) }

    let(:path) { described_class.call([all!, index!(1), :key]) }
    let(:value) do
      [
        ["skip", { key: "value1" }],
        ["skip", { key: "value2" }]
      ]
    end
    let(:state) { state!(value) }

    it { is_expected.to contain(["value1", "value2"]) }
  end
end
