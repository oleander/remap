# frozen_string_literal: true

# require "super_diff/rspec"

require "simplecov"
require "dry/configurable/test_interface"
require "bundler/setup"
require "factory_bot"
require "remap"
require "pry"

require_relative "factories"

using Remap::State::Extension

RSpec::Matchers.define :have do |count|
  match do |actual|
    actual.no_of_problems == count
  end

  chain :problems do
    @count = :problems
  end

  # custom error message for failure
  failure_message do |actual|
    detailed = JSON.pretty_generate(actual.problems)
    "expected #{actual} to have #{count} #{@count}, but it has #{actual.no_of_problems}: #{detailed}"
  end

  # custom error message for negative failure
  failure_message_when_negated do |actual|
    detailed = JSON.pretty_generate(actual.problems)
    "expected #{actual} to not have #{count} #{@count}, but it has #{actual.no_of_problems}: #{detailed}"
  end
end

RSpec::Matchers.define :contain do |expected|
  match do |actual|
    (actual.fetch(:value) { return false } === expected || actual.fetch(:value) == expected)
  end

  # custom error message for failure using json pretty print on actual.value
  failure_message do |actual|
    "expected #{JSON.pretty_generate(actual.value)} to contain #{expected}"
  rescue KeyError
    "expected actual to contain #{expected} but it contains nothing"
  end

  # custom error message for negative failure using json pretty print on actual.value
  failure_message_when_negated do |actual|
    "expected #{JSON.pretty_generate(actual.value)} not to contain #{expected}"
  end
end

module Support
  include Dry::Core::Constants

  module Types
    include Dry::Types()
  end

  def defined!(value = value!, *traits, **options)
    build(:state, *traits, value: value, **options)
  end

  def undefined!(*traits)
    build(:undefined, *traits)
  end

  def state!(value = value!, path: [], input: value, **options)
    FactoryBot.build(:defined, value: value, path: path, input: input, options: options)
  end
  alias null! state!

  def path!(input: nil, output: nil)
    FactoryBot.build(Remap::Rule::Path, **{ input: input, output: output }.compact)
  end

  def undefined!(*traits)
    FactoryBot.build(:undefined, *traits)
  end

  def void!
    Remap::Rule::Void.call({})
  end
  alias rule! void!

  def index!(idx)
    Remap::Selector::Index.call(index: idx)
  end

  def map!(val = Undefined, &block)
    map = Remap::Rule::Map.call(path: { to: [], map: [] }, rule: void!)

    if val == Undefined
      map.adjust(&block)
    else
      map.adjust { v }
    end
  end

  def pending!(*args)
    map = Remap::Rule::Map.call(path: { to: [], map: [] }, rule: void!)
    map.pending(*args)
    map
  end

  def context!(value = nil)
    FactoryBot.build(Remap::Context::Value, **{ value: value }.compact)
  end

  def hash!(max = 3)
    Faker::Types.complex_rb_hash(number: max)
  end
  alias value! hash!

  def mapper!(options = {}, &block)
    FactoryBot.build(:mapper, options: options).tap do |mapper|
      if block
        mapper.class_eval(&block)
      end
    end
  end

  def static!(value)
    Remap::Static::Fixed.call(value: value)
  end

  def problem!(*reason)
    map! do
      skip!(*reason)
    end
  end

  def all!
    Remap::Selector::All.call({})
  end

  def first!
    Remap::Selector::Index.call({ index: 0 })
  end

  def string!
    Faker::Types.rb_string #=> "foobar"
  end

  def symbol!
    :symbol
  end

  def array!(_max = 3)
    Faker::Types.rb_array(len: 3)
  end

  def int!
    100
  end

  module Extension
    refine Remap::Rule::Path do
      def output(value)
        to.reverse.reduce(value) do |val, key|
          { key => val }
        end
      end

      def input(value)
        map.segments.reverse.reduce(value) do |val, segment|
          { segment.key => val }
        end
      end

      def state(value)
        Remap::State.new(input(value))
      end

      def expect(value)
        output(value)
      end
    end
  end
end

# module Remap
#   class Base
#     enable_test_interface
#   end
# end

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.include Support
  # config.before(:all) { Remap::Base.reset_config }
  config.include Dry::Monads[:maybe, :result, :do]
  config.filter_run_when_matching :focus
  config.order = :random
  config.example_status_persistence_file_path = ".rspec_status"
  config.include FactoryBot::Syntax::Methods
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.expect_with :rspec do |c|
    c.max_formatted_output_length = nil
  end
end

RSpec.shared_examples Remap do |options = {}|
  subject { mapper.new(**options).call(input) }

  it { is_expected.to match(output) }
end

RSpec::Matchers.define :succeed do
  include Dry::Monads[:result]

  match do |actual|
    if @with
      actual == Success(@with)
    else
      actual.success?
    end
  end

  chain :with do |value|
    @with = value
  end
end

RSpec.shared_examples Remap::Rule::Map do
  subject do
    described_class.call(
      rule: build(:void),
      path: { to: to, map: from }
    ).call(state.result(input))
  end

  it { is_expected.to include(output) }
end

# RSpec.shared_examples Remap::Rule::Collection::Filled do
#   it_behaves_like Remap::Rule::Collection
# end

RSpec.shared_examples Remap::Rule::Collection::Empty do
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

# module State
#   class Scope < Struct
#     attribute :value, Types::Any.maybe
#     attribute :mapper, Types::Mapper
#   end

#   class Element < Struct
#     attribute :index, Types::Integer
#     attribute :element, Types::Any
#   end

#   class Value < Struct
#     attribute :value, Types::Any
#     attribute :key, Types::Key
#   end
# end

# define do           # sets: #scope[mapper, value] & #values
#   each do          # sets: #element[index, element]
#     map :a, to: :b do # sets: #value[key, value]
#       embed X      # sets: #scope[mapper, value]
#     end
#   end
# end

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
