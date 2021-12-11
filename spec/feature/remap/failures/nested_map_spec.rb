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
          failures: contain_exactly(have_attributes(value: { age: 50 }, path: [:person, :name]))
        )
      )
    end
  end

  context "when key points to the wrong data type" do
    let(:input) do
      { person: "hes 50 years old" }
    end

    it "raises an exception" do
      expect { mapper.call(input, &error) }.to raise_error(
        an_instance_of(Remap::Notice::Fatal).and(
          having_attributes(
            value: "hes 50 years old",
            path: [:person, :name]
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
