# frozen_string_literal: true

module Support
  include Dry::Core::Constants
  include Remap

  def Failure(**options)
    Failure.new(reasons: options)
  end

  # @return [Remap::Rule::Void]
  def void!
    Rule::Void.call(EMPTY_HASH)
  end
  alias rule! void!

  # @return [Remap::Rule::Map]
  def map!(&block)
    Rule::Map.call(rule: void!).adjust(&block)
  end

  # @return [Remap::Rule::Map]
  def pending!(*args)
    Rule::Map.call(rule: void!).pending(*args)
  end

  # @return [Hash]
  def hash!(max = 3)
    Faker::Types.complex_rb_hash(number: max)
  end
  alias value! hash!

  # @return [Remap::Static::Fixed]
  def static!(value)
    Static::Fixed.call(value: value)
  end

  # @return [Selector::All]
  def all!
    Selector::All.call({})
  end

  # @return [Selector::Index]
  def index!(idx)
    Selector::Index.call(index: idx)
  end

  # @return [Selector::Index]
  def first!
    index!(0)
  end

  # A random hash
  #
  # @param value [T]
  #
  # @return [Hash] (State<T>)
  def defined!(value = value!, *traits, **options)
    build(:state, *traits, value: value, **options)
  end

  # @return [Hash]
  def undefined!(*traits)
    build(:undefined, *traits)
  end

  # @return [Hash]
  def state!(value = value!, input: value, **options)
    build(:defined, value: value, input: input, **options)
  end

  # @return [Array<Key>]
  def path!(**options)
    build("remap/path", **options)
  end

  # A mapper class with {options} as required attributes
  #
  # @param options [Hash]
  #
  # @return [Remap::Mapper::Class]
  def mapper!(options = EMPTY_HASH, &block)
    build(:mapper, options: options).tap do |mapper|
      if block
        mapper.class_eval(&block)
      end
    end
  end

  # @return [Remap::Rule::Map]
  def problem!(*reason)
    map! { skip!(*reason) }
  end

  # @return [String]
  def string!
    Faker::Types.rb_string
  end

  # A random array with length {max}
  #
  # @return [Array]
  def array!(max = 3)
    Faker::Types.rb_array(len: max)
  end

  # A random int
  #
  # @return [Integer]
  def int!
    Faker::Number.number(digits: 1)
  end

  # A random symbol
  #
  # @return [Symbol]
  def symbol!
    string!.to_sym
  end
end
