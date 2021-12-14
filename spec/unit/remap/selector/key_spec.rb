# frozen_string_literal: true

xdescribe Remap::Selector::Key do
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

    context "when input is not a hash" do
      let(:input) { [] }

      it "raises a fatal exception" do
        expect { selector.call(state, &error) }.to raise_error(
          an_instance_of(Remap::Notice::Fatal).and(
            having_attributes(
              value: input
            )
          )
        )
      end
    end

    context "when input is a hash" do
      context "when input contains key" do
        let(:input) { { key => value } }

        it "invokes block" do
          expect do |b|
            selector.call(state, &b)
          end.to yield_with_args(contain(value))
        end
      end

      context "when input does not contain the key" do
        let(:input) { { not: value } }

        it "raises a fatal exception" do
          expect { selector.call(state, &error) }.to raise_error(
            an_instance_of(Remap::Notice::Ignore).and(
              having_attributes(
                value: input
              )
            )
          )
        end
      end
    end
  end
end
