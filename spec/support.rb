# frozen_string_literal: true

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
    build(:defined, value: value, path: path, input: input, options: options)
  end
  alias null! state!

  def path!(input: nil, output: nil)
    build(Remap::Rule::Path, **{ input: input, output: output }.compact)
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
    build(Remap::Context::Value, **{ value: value }.compact)
  end

  def hash!(max = 3)
    Faker::Types.complex_rb_hash(number: max)
  end
  alias value! hash!

  def mapper!(options = {}, &block)
    build(:mapper, options: options).tap do |mapper|
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
