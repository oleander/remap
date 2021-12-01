# frozen_string_literal: true

describe Remap::Notice do
  let(:input) { { path: [:a, :b, :c], value: value!, reason: string! } }

  describe "::call" do
    context "when input contains a backtrace" do
      subject { described_class.call(**input) }

      it { is_expected.to be_kind_of(described_class) }
    end

    context "when input does not contain a backtrace" do
      subject { described_class.call(**input) }

      it { is_expected.to be_kind_of(described_class) }
    end
  end
end
