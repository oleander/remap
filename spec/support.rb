# frozen_string_literal: true

module Support
  include Dry::Core::Constants
  include Remap

  def error
    -> failure { raise failure.exception }
  end

  # @return [Remap::Rule::Void]
  def void!
    Rule::Void.call(EMPTY_HASH)
  end
  alias rule! void!

  def notice!
    Notice.call(value: value!, path: [:a], reason: string!)
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
  def path!(input = Undefined, output = Undefined, **options)
    input_path = Undefined.default(input, options.fetch(:input, EMPTY_ARRAY))
    output_path = Undefined.default(output, options.fetch(:output, EMPTY_ARRAY))

    { input: input_path!(input_path), output: output_path!(output_path) }
  end

  def input_path!(path = [])
    Path::Input.new(path)
  end

  def output_path!(path = [])
    Path::Output.new(path)
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

  # A random symbol
  #
  # @return [Symbol]
  def symbol!
    string!.to_sym
  end
end
