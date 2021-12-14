# frozen_string_literal: true

describe Remap::Base do
  using Remap::Extensions::Enumerable
  using Remap::State::Extension

  let(:mapper) do
    mapper! do
      contract do
        required(:age).filled(:integer)
      end

      rule(:age) do
        unless value >= 18
          key.failure("too young")
        end
      end

      define do
        map :age, to: [:person, :age]
      end
    end
  end

  context "when age is to low" do
    let(:input) do
      { age: 10 }
    end

    xit "invokes block with failure" do
      expect { |e| mapper.call(input, &e) }.to yield_and_return(
        an_instance_of(Remap::Failure).and(
          have_attributes(
            failures: contain_exactly(
              an_instance_of(Remap::Notice).and(
                have_attributes(
                  path: [:age]
                )
              )
            )
          )
        )
      )
    end
  end

  context "when age higher" do
    let(:input) do
      { age: 100 }
    end

    it "invokes block with failure" do
      expect { |e| mapper.call(input, &e) }.not_to yield_control
    end
  end
end
