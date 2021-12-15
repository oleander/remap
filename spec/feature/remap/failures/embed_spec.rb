# frozen_string_literal: true

describe Remap::Base do
  let(:person) do
    mapper! do
      define do
        to :person do
          map :name
        end
      end
    end
  end

  let(:mapper) do |context: self|
    mapper! do
      define do
        embed context.person
        get :car
      end
    end
  end

  context "when the embeded mapper contains missing field" do
    let(:input) { { cat: "Volvo" } }

    it "raises an exception" do
      expect { |b| mapper.call(input, &b) }.to yield_with_args(
        an_instance_of(Remap::Failure).and(
          have_attributes(
            failures: contain_exactly(have_attributes(value: input, path: [:name]))
          )
        )
      )
    end
  end

  context "when the outer mapper fails" do
    let(:input) { { name: "John" } }

    it "raises an exception" do
      expect { |b| mapper.call(input, &b) }.to yield_with_args(
        an_instance_of(Remap::Failure).and(
          have_attributes(
            failures: contain_exactly(have_attributes(value: input, path: [:car]))
          )
        )
      )
    end
  end
end
