# frozen_string_literal: true

describe Remap::Selector::Key do
  using Remap::State::Extension

  let(:key) { :key }

  describe "::call" do
    context "when called without hash" do
      subject { described_class.call(key) }

      it { is_expected.to be_a(described_class) }
      it { is_expected.to have_attributes(key: key) }
    end

    context "when called with a hash" do
      subject { described_class.call({ key: key }) }

      it { is_expected.to be_a(described_class) }
      it { is_expected.to have_attributes(key: key) }
    end
  end

  describe "#call" do
    subject(:selector) { described_class.call(key) }

    let(:value) { string! }
    let(:key)   { symbol!       }
    let(:state) { state!(input) }

    context "without block" do
      subject(:result) { selector.call(state) }

      context "when input is not a hash" do
        let(:input) { [] }

        its(:itself) { will throw_symbol(:fatal, be_a(Remap::Notice)) }
      end

      context "when input is a hash" do
        context "when input contains key" do
          let(:input) { { key => value } }

          it { is_expected.to contain(value) }
        end

        context "when input does not key" do
          let(:input) { {} }

          its(:itself) { will throw_symbol(:ignore, be_a(Remap::Notice)) }
        end
      end
    end

    context "with block" do
      context "when input is not a hash" do
        subject { selector.call(state) }

        let(:input) { [] }

        its(:itself) { will throw_symbol(:fatal, be_a(Remap::Notice)) }
      end

      context "when input is a hash" do
        subject { selector.call(state) }

        context "when input contains key" do
          let(:input) { { key => value } }

          it "invokes block" do
            expect do |b|
              selector.call(state, &b)
            end.to yield_with_args(contain(value))
          end
        end

        context "when input does not contain the key" do
          let(:input) { {} }

          its(:itself) { will throw_symbol(:ignore, be_a(Remap::Notice)) }
        end
      end
    end
  end
end
