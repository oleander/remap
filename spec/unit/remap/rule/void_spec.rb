# frozen_string_literal: true

describe Remap::Rule::Void do
  subject(:rule) { described_class.new }

  let(:value) { { "foo" => "bar" } }
  let(:state) { state!(value) }

  it "returns its input" do
    expect(rule.call(state)).to contain(value)
  end
end
