# frozen_string_literal: true

shared_examples "a success" do
  it { is_expected.to have(0).problems }
  it { is_expected.to contain(expected) }
end

shared_examples Remap::Base do |options = {}|
  subject { mapper.call(input, **options) }

  it { is_expected.to have_attributes(to_hash: include(output).or(include(success: output))) }
end
