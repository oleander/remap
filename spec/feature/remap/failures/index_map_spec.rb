# frozen_string_literal: true

describe Remap::Base do
  let(:mapper) do
    mapper! do
      define do
        map :people, at(1) do
          get :name
        end
      end
    end
  end

  context "when key after the selector is not defined" do
    let(:input) do
      { people: [{ name: "John" }, { not_a_match: "Lisa" }] }
    end

    it "invokes block with failure" do
      expect { |b| mapper.call(input, &b) }.to yield_with_args(
        be_an_instance_of(Remap::Failure).and(
          have_attributes(
            failures: contain_exactly(
              have_attributes(
                value: { not_a_match: "Lisa" },
                reason: include("name"),
                path: [:people, 1]
              )
            )
          )
        )
      )
    end
  end

  context "when there are too few elements" do
    let(:input) do
      { people: [{ name: "John" }] }
    end

    it "invokes block with failure" do
      expect { |b| mapper.call(input, &b) }.to yield_with_args(
        be_an_instance_of(Remap::Failure).and(
          have_attributes(
            failures: contain_exactly(have_attributes(path: [:people]))
          )
        )
      )
    end
  end

  context "when key before the selector is not defined" do
    let(:input) do
      { animal: [{ name: "Peter" }, { name: "Lisa" }] }
    end

    it "invokes block with failure" do
      expect { |b| mapper.call(input, &b) }.to yield_with_args(
        an_instance_of(Remap::Failure).and(
          have_attributes(
            failures: contain_exactly(
              have_attributes(
                reason: include("people"),
                path: be_empty,
                value: input
              )
            )
          )
        )
      )
    end
  end

  context "when key points to the wrong data type" do
    let(:string) { "not a hash" }

    let(:input) do
      { people: [{ name: "John" }, string] }
    end

    it "raises an exception" do
      expect { mapper.call(input, &error) }.to raise_error(
        an_instance_of(Remap::Failure::Error).and(
          having_attributes(
            failures: contain_exactly(having_attributes(path: [:people, 1], value: string))
          )
        )
      )
    end
  end

  context "when key is defined" do
    let(:input) do
      { people: [{ name: "John" }, { name: "Lisa" }] }
    end

    it "returns a state containing the value" do
      expect(mapper.call(input, &error)).to eq({ name: "Lisa" })
    end
  end
end
