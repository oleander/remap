# frozen_string_literal: true

using Remap::State::Extension

shared_examples Remap::Base do |options = {}|
  subject { mapper.call(input, **options) }

  it { is_expected.to match(output) }
end

shared_examples "a fatal exception" do
  let(:state) do
    super().merge(
      fatal_id: super().fetch(:fatal_id, :fatal_id)
    )
  end

  let(:fatal_id) { state.fatal_id }

  it "raises a fatal exception" do
    expect { result }.to throw_symbol(
      fatal_id, an_instance_of(Remap::Failure).and(
        having_attributes(
          failures: contain_exactly(
            an_instance_of(Remap::Notice).and(
              having_attributes(attributes)
            )
          )
        )
      )
    )
  end
end

shared_examples "an ignored exception" do
  let(:reason) { "this is a reason" }
  let(:state) do
    super().merge(
      id: super().fetch(:id, :ignore_id)
    )
  end

  it "throws an ignored symbol" do
    expect { result }.to throw_symbol(
      state.id, include(
        notices: contain_exactly(
          an_instance_of(Remap::Notice).and(
            having_attributes(attributes)
          )
        )
      )
    )
  end
end
