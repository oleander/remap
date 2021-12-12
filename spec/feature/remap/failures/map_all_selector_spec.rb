# frozen_string_literal: true

describe Remap::Base do
  let(:mapper) do
    mapper! do
      define do
        map :people, all, :name
      end
    end
  end

  context "when key after the selector is not defined" do
    let(:input) do
      { people: [{ does_not_match: "with John" }] }
    end

    it "invokes block with failure" do
      expect { |b| mapper.call(input, &b) }.to yield_with_args(
        be_an_instance_of(Remap::Failure).and(
          have_attributes(
            failures: contain_exactly(
              have_attributes(
                value: { does_not_match: "with John" },
                path: [:people, 0, :name]
              )
            )
          )
        )
      )
    end
  end

  context "when key before the selector is not defined" do
    let(:input) do
      { animal: [{ name: "Peter" }] }
    end

    it "invokes block with failure" do
      expect { |b| mapper.call(input, &b) }.to yield_with_args(
        an_instance_of(Remap::Failure).and(
          have_attributes(
            failures: contain_exactly(have_attributes(value: input, path: [:people]))
          )
        )
      )
    end
  end

  context "when key points to the wrong data type" do
    let(:input) do
      { people: "he's 50 years old" }
    end

    it "raises an exception" do
      expect { mapper.call(input, &error) }.to raise_error(
        an_instance_of(Remap::Notice::Traced).and(
          having_attributes(
            value: "he's 50 years old",
            path: [:people]
          )
        )
      )
    end
  end

  context "when key is defined" do
    let(:input) do
      { people: [{ name: "John" }] }
    end

    it "returns a state containing the value" do
      expect(mapper.call(input, &error)).to eq(["John"])
    end
  end
end
