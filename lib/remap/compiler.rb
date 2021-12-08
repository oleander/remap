# frozen_string_literal: true

module Remap
  # Constructs a {Rule} from the block passed to {Remap::Base.define}
  class Compiler < Proxy
    # @return [Array<Rule>]
    param :rules, type: Types.Array(Rule)

    # @return [Rule]
    delegate :call, to: Compiler

    # Constructs a rule tree given block
    #
    # @example Compiles two rules
    #   rule = Remap::Compiler.call do
    #     get :name
    #     get :age
    #   end
    #
    #   state = Remap::State.call({
    #     name: "John",
    #     age: 50
    #   })
    #
    #   error = -> failure { raise failure.exception }
    #
    #   rule.call(state, &error).fetch(:value) # => { name: "John", age: 50 }
    #
    # @return [Rule]
    def self.call(&block)
      unless block
        return Rule::Void.new
      end

      new([]).tap do |compiler|
        compiler.instance_exec(&block)
      end.rule
    end

    # Maps input path [input] to output path [to]
    #
    # @param path ([]) [Array<Segment>, Segment]
    # @param to ([]) [Array<Symbol>, Symbol]
    #
    # @return [Rule::Map::Required]
    def map(*path, to: EMPTY_ARRAY, backtrace: Kernel.caller, &block)
      add Rule::Map::Required.call(
        path: {
          output: [to].flatten,
          input: path.flatten
        },
        backtrace: backtrace,
        rule: call(&block))
    end

    # Optional version of {#map}
    #
    # @see #map
    #
    # @return [Rule::Map::Optional]
    def map?(*path, to: EMPTY_ARRAY, backtrace: Kernel.caller, &block)
      add Rule::Map::Optional.call(
        path: {
          output: [to].flatten,
          input: path.flatten
        },
        backtrace: backtrace,
        rule: call(&block))
    end

    # Select a path and uses the same path as output
    #
    # @param path ([]) [Array<Segment>, Segment]
    #
    # @return [Rule::Map::Required]
    def get(*path, backtrace: Kernel.caller, &block)
      map(path, to: path, backtrace: backtrace, &block)
    end

    # Optional version of {#get}
    #
    # @see #get
    #
    # @return [Rule::Map::Optional]
    def get?(*path, backtrace: Kernel.caller, &block)
      map?(path, to: path, backtrace: backtrace, &block)
    end

    # Maps using mapper
    #
    # @param mapper [Remap]
    #
    # @return [Rule::Embed]
    def embed(mapper)
      add Rule::Embed.new(mapper: mapper)
    rescue Dry::Struct::Error
      raise ArgumentError, "Embeded mapper must be [Remap::Mapper], got [#{mapper}]"
    end

    # @param path ([]) [Symbol, Array<Symbol>]
    # @option to [Remap::Static]
    #
    # @return [Rule::Set]
    # @raise [ArgumentError]
    #   if no path given
    #   if path is not a Symbol or Array<Symbol>
    def set(*path, to:)
      add Rule::Set.new(path: path.flatten, value: to)
    rescue Dry::Struct::Error => e
      raise ArgumentError, e.message
    end

    # Maps to path from map with block in between
    #
    # @param path [Array<Symbol>, Symbol]
    # @param map [Array<Segment>, Segment]
    #
    # @return [Rule::Map]
    def to(*path, map: EMPTY_ARRAY, backtrace: Kernel.caller, &block)
      map(*map, to: path, backtrace: backtrace, &block)
    end

    # Optional version of {#to}
    #
    # @see #to
    #
    # @return [Rule::Map::Optional]
    def to?(*path, map: EMPTY_ARRAY, &block)
      map?(*map, to: path, &block)
    end

    # Iterates over the input value, passes each value
    # to its block and merges the result back together
    #
    # @return [Rule::Each]]
    # @raise [ArgumentError] if no block given
    def each(&block)
      unless block
        raise ArgumentError, "#each requires a block"
      end

      add Rule::Each.new(rule: call(&block))
    end

    # Wraps output in type
    #
    # @param type [:array]
    #
    # @yieldreturn [Rule]
    #
    # @return [Rule::Wrap]
    # @raise [ArgumentError] if type is not :array
    def wrap(type, &block)
      unless block
        raise ArgumentError, "#wrap requires a block"
      end

      add Rule::Wrap.new(type: type, rule: call(&block))
    rescue Dry::Struct::Error => e
      raise ArgumentError, e.message
    end

    # Selects all elements
    #
    # @return [Rule::Path::Segment::Quantifier::All]
    def all
      Selector::All.new(EMPTY_HASH)
    end

    # Static value to be selected
    #
    # @param value [Any]
    #
    # @return [Rule::Static::Fixed]
    def value(value)
      Static::Fixed.new(value: value)
    end

    # Static option to be selected
    #
    # @param id [Symbol]
    #
    # @return [Rule::Static::Option]
    def option(id, backtrace: Kernel.caller)
      Static::Option.new(name: id, backtrace: backtrace)
    end

    # Selects index element in input
    #
    # @param index [Integer]
    #
    # @return [Path::Segment::Key]
    # @raise [ArgumentError] if index is not an Integer
    def at(index)
      Selector::Index.new(index: index)
    rescue Dry::Struct::Error
      raise ArgumentError,
            "Selector at(index) requires an integer argument, got [#{index}] (#{index.class})"
    end

    # Selects first element in input
    #
    # @return [Path::Segment::Key]]
    def first
      at(0)
    end
    alias any first

    # Selects last element in input
    #
    # @return [Path::Segment::Key]
    def last
      at(-1)
    end

    # The final rule
    #
    # @return [Rule]
    def rule
      Rule::Collection.call(rules: rules)
    end

    private

    def add(rule)
      rule.tap { rules << rule }
    end
  end
end
