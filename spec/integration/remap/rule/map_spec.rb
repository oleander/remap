# frozen_string_literal: true

describe Remap::Rule::Map do
  using Remap::State::Extension
  using Remap::Extensions::Object

  subject { map.call(context, &error) }

  let(:input)   { 10                                            }
  let(:context) { state!(input)                                 }
  let(:map)     { described_class::Optional.new(path: path!, rule: void!, backtrace: caller) }

  describe "#enum" do
    before do
      map.enum do
        value "HIT"
      end
    end

    context "when missed" do
      let(:input) { "MISS" }

      its([:notices]) { is_expected.to have(1).items }
      it { is_expected.not_to contain(input) }
    end

    context "when hit" do
      let(:input) { "HIT" }

      its([:notices]) { is_expected.to be_empty }
      it { is_expected.to contain(input) }
    end
  end

  describe "#pending" do
    context "without reason" do
      before do
        map.pending
      end

      its([:notices]) { is_expected.to have(1).items }
    end

    context "with reason" do
      before do
        map.pending("nope")
      end

      its([:notices]) { is_expected.to have(1).items }
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

      its([:notices]) { is_expected.to have(1).items }
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

      its([:notices]) { is_expected.to have(1).items }
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
          Dry::Core::Constants::Undefined
        end
      end

      its([:notices]) { is_expected.to have(1).items }
    end

    context "when #fetch is called" do
      context "when given a hash" do
        before do
          map.adjust do |value|
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

          its([:notices]) { is_expected.to have(1).items }
        end
      end

      context "when given an array" do
        before do
          map.adjust do |value|
            value.fetch(1)
          end
        end

        context "when the index exists" do
          let(:input) { [:one, :two, :three] }

          it { is_expected.to contain(:two) }
        end

        context "when the index does not exist" do
          let(:input) { [:one] }

          its([:notices]) { is_expected.to have(1).items }
        end
      end

      context "when caller does not respond to #fetch" do
        before do
          map.adjust do |value|
            value.fetch(1)
          end
        end

        let(:input) { 100_000 }

        its([:notices]) { is_expected.to have(1).items }
      end
    end

    context "when skipping a mapping skip!" do
      context "without reason" do
        before do
          map.adjust do |&error|
            error["my reason"]
          end
        end

        its([:notices]) { is_expected.to have(1).items }
      end

      context "with reason" do
        before do
          map.adjust do |&error|
            error["my reason"]
          end
        end

        its([:notices]) { is_expected.to have(1).items }
      end
    end
  end
end
