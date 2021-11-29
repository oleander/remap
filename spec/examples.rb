# frozen_string_literal: true

shared_examples Remap do |options = {}|
  subject { mapper.new(**options).call(input) }

  it { is_expected.to match(output) }
end

shared_examples Remap::Rule::Map do
  subject do
    described_class.call(
      rule: build(:void),
      path: { to: to, map: from }
    ).call(state.result(input))
  end

  it { is_expected.to include(output) }
end

shared_examples Remap::Rule::Collection::Empty do
  it_behaves_like Remap::Rule::Collection do
    let(:rules) { [] }
  end
end

shared_examples Remap::Rule::Collection::Filled do
  subject { rule.call(new_state) }

  let(:rule) { described_class.call(rules: rules) }
  let(:new_state) { state.result(input) }

  it { is_expected.to be_a(Remap::State) }
end

shared_examples "a success" do
  it { is_expected.to have(0).problems }
  it { is_expected.to contain(expected) }
end

shared_examples Remap::Base do |options = {}|
  subject { mapper.call(input, **options) }

  it { is_expected.to have_attributes(to_hash: include(output).or(include(success: output))) }

  after do |example|
    if example.metadata[:last_run_status] == "failed"
      mapper.call(input, **options) do |result|
        pp result
      end
    end
  end
end
