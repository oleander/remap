# frozen_string_literal: true

describe Remap::Base do
  let(:mapper) do
    mapper! do
      define do
        map :person do
          map :name
        end
      end
    end
  end

  context "when key is not defined" do
    let(:input) do
      { person: { age: 50 } }
    end

    it "invokes block with failure" do
      expect { |b| mapper.call(input, &b) }.to yield_with_args(
        have_attributes(
          failures: contain_exactly(have_attributes(value: { age: 50 }, path: [:person], reason: include("name")))
        )
      )
    end
  end

  context "when key points to the wrong data type" do
    let(:string) { "not a hash" }

    let(:input) do
      { person: string }
    end

    it "raises an exception" do
      expect { mapper.call(input, &error) }.to raise_error(
        an_instance_of(Remap::Failure::Error).and(
          having_attributes(
            failures: contain_exactly(having_attributes(path: [:person], value: string))
          )
        )
      )
    end
  end

  context "when key is defined" do
    let(:input) do
      { person: { name: "John" } }
    end

    it "returns a state containing the value" do
      expect(mapper.call(input, &error)).to eq("John")
    end
  end
end
