# frozen_string_literal: true

describe Remap::Rule::Map do
  using Remap::State::Extension

  subject { map.call(context) }

  let(:input) { 10 }
  let(:context) { state!(input) }
  let(:map) { described_class.new(path: path!, rule: void! ) }

  describe "#enum" do
    before do
      map.enum do
        value "HIT"
      end
    end

    context "when missed" do
      let(:input) { "MISS" }

      it { is_expected.to have(1).problems }
      it { is_expected.not_to contain(input) }
    end

    context "when hit" do
      let(:input) { "HIT" }

      it { is_expected.to have(0).problems }
      it { is_expected.to contain(input) }
    end
  end

  describe "#pending" do
    context "without reason" do
      before do
        map.pending
      end

      it { is_expected.to have(1).problems }
    end

    context "with reason" do
      before do
        map.pending("nope")
      end

      it { is_expected.to have(1).problems }
    end
  end

  describe "#if" do
    let(:input) { 10 }
    let(:output) { input }

    context "when block is true" do
      before do
        map.if(&:even?)
      end

      it { is_expected.to contain(output) }
    end

    context "when block is false" do
      before do
        map.if(&:odd?)
      end

      it { is_expected.to have(1).problems }
    end
  end

  describe "#if_not" do
    let(:input) { 10 }
    let(:output) { input }

    context "when block is true" do
      before do
        map.if_not(&:odd?)
      end

      it { is_expected.to contain(output) }
    end

    context "when block is false" do
      before do
        map.if_not(&:even?)
      end

      it { is_expected.to have(1).problems }
    end
  end

  describe "#then" do
    let(:output) { input.next }

    before do
      map.then(&:next)
    end

    it { is_expected.to contain(output) }
  end

  describe "#adjust" do
    let(:input) { 10 }

    context "when using input argument" do
      let(:output) { input.next }

      before do
        map.adjust(&:next)
      end

      it { is_expected.to contain(output) }
    end

    context "when passing proc" do
      let(:output) { input.next }

      before do
        map.adjust(&:next)
      end

      it { is_expected.to contain(output) }
    end

    context "when accessing #input" do
      let(:output) { input }

      before do
        map.adjust do
          input
        end
      end

      it { is_expected.to contain(output) }
    end

    context "when Undefined is returned from the block" do
      let(:output) { input }

      before do
        map.adjust do
          Undefined
        end
      end

      it { is_expected.to have(1).problems }
    end

    context "when #fetch is called" do
      context "when given a hash" do
        before do
          map.adjust do
            value.fetch(:key)
          end
        end

        let(:value) { value! }

        context "when the key exists" do
          let(:input) { { key: value } }

          it { is_expected.to contain(value) }
        end

        context "when the key does not exist" do
          let(:input) { { other: value } }

          it { is_expected.to have(1).problems }
        end
      end

      context "when given an array" do
        before do
          map.adjust do
            value.fetch(1)
          end
        end

        context "when the index exists" do
          let(:input) { [:one, :two, :three] }

          it { is_expected.to contain(:two) }
        end

        context "when the index does not exist" do
          let(:input) { [:one] }

          it { is_expected.to have(1).problems }
        end
      end

      context "when caller does not respond to #fetch" do
        before do
          map.adjust do
            value.fetch(1)
          end
        end

        let(:input) { 100_000 }

        it { is_expected.to have(1).problems }
      end
    end

    context "when skipping a mapping skip!" do
      context "without reason" do
        before do
          map.adjust do
            skip!
          end
        end

        it { is_expected.to have(1).problems }
      end

      context "with reason" do
        before do
          map.adjust do
            skip!("nope")
          end
        end

        it { is_expected.to have(1).problems }
      end
    end
  end
end
