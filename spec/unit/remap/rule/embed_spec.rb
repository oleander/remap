# frozen_string_literal: true

describe Remap::Rule::Embed do
  subject(:rule) { described_class.call(mapper: mapper) }

  let(:mapper) { build(:mapper) }

  describe "#call" do
    subject { rule.call(state, &error) }

    context "when state is undefined" do
      let(:state) { undefined! }

      it { is_expected.not_to have_key(:value) }
      it { is_expected.not_to have_key(:mapper) }
      it { is_expected.not_to have_key(:scope) }
    end

    context "when state is defined" do
      let(:state) { defined! }

      context "when mapper yields failure" do
        let(:mapper) do
          mapper! do
            define do
              map.then do
                skip!
              end
            end
          end
        end

        it "yields failure" do
          expect { |error| rule.call(state, &error) }.to yield_with_args(an_instance_of(Remap::Failure))
        end
      end

      context "when mapper throws fatal" do
        let(:state) { state!({ key: "value" }) }

        let(:mapper) do
          mapper! do
            define do
              map :key, all
            end
          end
        end

        it "raises an error" do
          expect { rule.call(state, &error) }.to raise_error(Remap::Error)
        end
      end

      context "when #mapper is accessed" do
        let(:mapper) do
          mapper! do
            define do
              map.then do
                mapper
              end
            end
          end
        end

        it { is_expected.to contain(mapper) }
        it { is_expected.not_to have_key(:mapper) }
        it { is_expected.not_to have_key(:scope) }
      end

      context "when #scope is accessed" do
        let(:value) { "<VALUE>" }
        let(:state) { state!(value) }

        let(:mapper) do
          mapper! do
            define do
              map.then do
                scope
              end
            end
          end
        end

        it { is_expected.to contain(value) }
        it { is_expected.not_to have_key(:mapper) }
        it { is_expected.not_to have_key(:scope) }
      end

      context "when #values is accessed" do
        let(:value) { "<VALUE>" }
        let(:state) { state!(value) }

        let(:mapper) do
          mapper! do
            define do
              map.then do
                values
              end
            end
          end
        end

        it { is_expected.to contain(value) }
        it { is_expected.not_to have_key(:mapper) }
        it { is_expected.not_to have_key(:scope) }
      end
    end
  end
end
