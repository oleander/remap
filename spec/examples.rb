# frozen_string_literal: true

shared_examples Remap::Base do |options = {}|
  subject { mapper.call(input, **options) }

  it { is_expected.to match(output) }
end
