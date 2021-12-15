# frozen_string_literal: true

module Remap
  using State::Extension

  # Constructs a {Rule} from the block passed to {Remap::Base.define}
  class Compiler < Proxy
    # @return [Array<Rule>]
    param :rules, type: Types.Array(Rule)

    # @return [Rule]
    delegate :call, to: Compiler

    # Constructs a rule tree given block
    #
    # @example Compiles two rules, [get] and [map]
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
    def self.call(backtrace: caller, &block)
      unless block_given?
        return Rule::VOID
      end

      rules = new([]).tap do |compiler|
        compiler.instance_exec(&block)
      end.rules

      Rule::Block.new(backtrace: backtrace, rules: rules)
    end

    # Maps input path [input] to output path [to]
    #
    # @param path ([]) [Array<Segment>, Segment]
    # @param to ([]) [Array<Symbol>, Symbol]
    #
    # @example From path [:name] to [:nickname]
    #   rule = Remap::Compiler.call do
    #     map :name, to: :nickname
    #   end
    #
    #   state = Remap::State.call({
    #     name: "John"
    #   })
    #
    #   output = rule.call(state) do |failure|
    #     raise failure.exception
    #   end
    #
    #   output.fetch(:value) # => { nickname: "John" }
    #
    # @return [Rule::Map::Required]
    def map(*path, to: EMPTY_ARRAY, backtrace: caller, &block)
      add rule(*path, to: to, backtrace: backtrace, &block)
    end

    # Optional version of {#map}
    #
    # @example Map an optional field
    #   rule = Remap::Compiler.call do
    #     to :person do
    #       map? :age, to: :age
    #       map :name, to: :name
    #     end
    #   end
    #
    #   state = Remap::State.call({
    #     name: "John"
    #   })
    #
    #   output = rule.call(state) do |failure|
    #     raise failure.exception
    #   end
    #
    #   output.fetch(:value) # => { person: { name: "John" } }
    #
    # @see #map
    #
    # @return [Rule::Map::Optional]
    def map?(*path, to: EMPTY_ARRAY, backtrace: caller, &block)
      add rule?(*path, to: to, backtrace: backtrace, &block)
    end

    # Select a path and uses the same path as output
    #
    # @param path ([]) [Array<Segment>, Segment]
    #
    # @example Map from [:name] to [:name]
    #   rule = Remap::Compiler.call do
    #     get :name
    #   end
    #
    #   state = Remap::State.call({
    #     name: "John"
    #   })
    #
    #   output = rule.call(state) do |failure|
    #     raise failure.exception
    #   end
    #
    #   output.fetch(:value) # => { name: "John" }
    #
    # @return [Rule::Map::Required]
    def get(*path, backtrace: caller, &block)
      add rule(path, to: path, backtrace: backtrace, &block)
    end

    # Optional version of {#get}
    #
    # @example Map from [:name] to [:name]
    #   rule = Remap::Compiler.call do
    #     get :name
    #     get? :age
    #   end
    #
    #   state = Remap::State.call({
    #     name: "John"
    #   })
    #
    #   output = rule.call(state) do |failure|
    #     raise failure.exception
    #   end
    #
    #   output.fetch(:value) # => { name: "John" }
    #
    # @see #get
    #
    # @return [Rule::Map::Optional]
    def get?(*path, backtrace: caller, &block)
      add rule?(path, to: path, backtrace: backtrace, &block)
    end

    # Maps using mapper
    #
    # @param mapper [Remap]
    #
    # @example Embed mapper Car into a person
    #   class Car < Remap::Base
    #     define do
    #       map :car do
    #         map :name, to: :car
    #       end
    #     end
    #   end
    #
    #   rule = Remap::Compiler.call do
    #     map :person do
    #       embed Car
    #     end
    #   end
    #
    #   state = Remap::State.call({
    #     person: {
    #       car: {
    #         name: "Volvo"
    #       }
    #     }
    #   })
    #
    #   output = rule.call(state) do |failure|
    #     raise failure.exception
    #   end
    #
    #   output.fetch(:value) # => { car: "Volvo" }
    #
    # @return [Rule::Embed]
    def embed(mapper, backtrace: caller)
      if block_given?
        raise ArgumentError, "#embed does not take a block"
      end

      Types::Mapper[mapper] do
        raise ArgumentError, "Argument to #embed must be a mapper, got #{mapper.class}"
      end

      r = rule(backtrace: backtrace).add do |s0|
        _embed(s0, mapper, backtrace)
      end

      add r
    end

    def _embed(s0, mapper, backtrace)
      f0 = catch do |fatal_id|
        s1 = s0.set(fatal_id: fatal_id)
        s2 = s1.set(mapper: mapper)

        return mapper.call!(s2) do |f1|
          s3 = s2.set(notices: f1.notices + f1.failures)
          s3.return!
        end.except(:mapper, :scope)
      end

      raise f0.exception(backtrace)
    end

    # Set a static value
    #
    # @param path ([]) [Symbol, Array<Symbol>]
    # @option to [Remap::Static]
    #
    # @example Set static value to { name: "John" }
    #   rule = Remap::Compiler.call do
    #     set :name, to: value("John")
    #   end
    #
    #   state = Remap::State.call({})
    #
    #   output = rule.call(state) do |failure|
    #     raise failure.exception
    #   end
    #
    #   output.fetch(:value) # => { name: "John" }
    #
    # @example Reference an option
    #   rule = Remap::Compiler.call do
    #     set :name, to: option(:name)
    #   end
    #
    #   state = Remap::State.call({}, options: { name: "John" })
    #
    #   output = rule.call(state) do |failure|
    #     raise failure.exception
    #   end
    #
    #   output.fetch(:value) # => { name: "John" }
    #
    # @return [Rule::Set]
    # @raise [ArgumentError]
    #   if no path given
    #   if path is not a Symbol or Array<Symbol>
    def set(*path, to:, backtrace: caller)
      if block_given?
        raise ArgumentError, "#set does not take a block"
      end

      unless to.is_a?(Static)
        raise ArgumentError, "Argument to #set must be a static value, got #{to.class}"
      end

      add rule(to: path, backtrace: backtrace).add { to.call(_1) }
    end

    # Maps to path from map with block in between
    #
    # @param path [Array<Symbol>, Symbol]
    # @param map [Array<Segment>, Segment]
    #
    # @example From path [:name] to [:nickname]
    #   rule = Remap::Compiler.call do
    #     to :nickname, map: :name
    #   end
    #
    #   state = Remap::State.call({
    #     name: "John"
    #   })
    #
    #   output = rule.call(state) do |failure|
    #     raise failure.exception
    #   end
    #
    #   output.fetch(:value) # => { nickname: "John" }
    #
    # @return [Rule::Map]
    def to(*path, map: EMPTY_ARRAY, backtrace: caller, &block)
      add rule(*map, to: path, backtrace: backtrace, &block)
    end

    # Optional version of {#to}
    #
    # @example Map an optional field
    #   rule = Remap::Compiler.call do
    #     to :person do
    #       to? :age, map: :age
    #       to :name, map: :name
    #     end
    #   end
    #
    #   state = Remap::State.call({
    #     name: "John"
    #   })
    #
    #   output = rule.call(state) do |failure|
    #     raise failure.exception
    #   end
    #
    #   output.fetch(:value) # => { person: { name: "John" } }
    # @see #to
    #
    # @return [Rule::Map::Optional]
    def to?(*path, map: EMPTY_ARRAY, backtrace: caller, &block)
      add rule?(*map, to: path, backtrace: backtrace, &block)
    end

    # Iterates over the input value, passes each value
    # to its block and merges the result back together
    #
    # @example Map an array of hashes
    #   rule = Remap::Compiler.call do
    #     each do
    #       map :name
    #     end
    #   end
    #
    #   state = Remap::State.call([{
    #     name: "John"
    #   }, {
    #     name: "Jane"
    #   }])
    #
    #   output = rule.call(state) do |failure|
    #     raise failure.exception
    #   end
    #
    #   output.fetch(:value) # => ["John", "Jane"]
    #
    # @return [Rule::Each]]
    # @raise [ArgumentError] if no block given
    def each(backtrace: caller, &block)
      unless block_given?
        raise ArgumentError, "#each requires a block"
      end

      add rule(all, backtrace: backtrace, &block)
    end

    # Wraps output in type
    #
    # @param type [:array]
    #
    # @yieldreturn [Rule]
    #
    # @example Wrap an output value in an array
    #   rule = Remap::Compiler.call do
    #     wrap(:array) do
    #       map :name
    #     end
    #   end
    #
    #   state = Remap::State.call({
    #     name: "John"
    #   })
    #
    #   output = rule.call(state) do |failure|
    #     raise failure.exception
    #   end
    #
    #   output.fetch(:value) # => ["John"]
    #
    # @return [Rule::Wrap]
    # @raise [ArgumentError] if type is not :array
    def wrap(type, backtrace: caller, &block)
      unless block_given?
        raise ArgumentError, "#wrap requires a block"
      end

      unless type == :array
        raise ArgumentError, "Argument to #wrap must equal :array, got [#{type}] (#{type.class})"
      end

      add rule(backtrace: backtrace, &block).then { Array.wrap(_1) }
    end

    # Selects all elements
    #
    # @example Select all keys in array
    #   rule = Remap::Compiler.call do
    #     map all, :name, to: :names
    #   end
    #
    #   state = Remap::State.call([
    #     { name: "John" },
    #     { name: "Jane" }
    #   ])
    #
    #   output = rule.call(state) do |failure|
    #     raise failure.exception
    #   end
    #
    #   output.fetch(:value) # => { names: ["John", "Jane"] }
    #
    # @return [Rule::Path::Segment::Quantifier::All]
    def all
      if block_given?
        raise ArgumentError, "all selector does not take a block"
      end

      Selector::All.new(EMPTY_HASH)
    end

    # Static value to be selected
    #
    # @param value [Any]
    #
    # @example Set path to static value
    #   rule = Remap::Compiler.call do
    #     set :api_key, to: value("<SECRET>")
    #   end
    #
    #   state = Remap::State.call({})
    #
    #   output = rule.call(state) do |failure|
    #     raise failure.exception
    #   end
    #
    #   output.fetch(:value) # => { api_key: "<SECRET>" }
    #
    # @return [Rule::Static::Fixed]
    def value(value, backtrace: caller)
      if block_given?
        raise ArgumentError, "option selector does not take a block"
      end

      Static::Fixed.new(value: value, backtrace: backtrace)
    end

    # Static option to be selected
    #
    # @example Set path to option
    #   rule = Remap::Compiler.call do
    #     set :meaning_of_life, to: option(:number)
    #   end
    #
    #   state = Remap::State.call({}, options: { number: 42 })
    #
    #   output = rule.call(state) do |failure|
    #     raise failure.exception
    #   end
    #
    #   output.fetch(:value) # => { meaning_of_life: 42 }
    #
    # @param id [Symbol]
    #
    # @return [Rule::Static::Option]
    def option(id, backtrace: caller)
      if block_given?
        raise ArgumentError, "option selector does not take a block"
      end

      Static::Option.new(name: id, backtrace: backtrace)
    end

    # Selects index element in input
    #
    # @param index [Integer]
    #
    # @example Select value at index
    #   rule = Remap::Compiler.call do
    #     map :names, at(1), to: :name
    #   end
    #
    #   state = Remap::State.call({
    #     names: ["John", "Jane"]
    #   })
    #
    #   output = rule.call(state) do |failure|
    #     raise failure.exception
    #   end
    #
    #   output.fetch(:value) # => { name: "Jane" }
    #
    # @return [Path::Segment::Key]
    # @raise [ArgumentError] if index is not an Integer
    def at(index)
      if block_given?
        raise ArgumentError, "first selector does not take a block"
      end

      Selector::Index.new(index: index)
    rescue Dry::Struct::Error
      raise ArgumentError,
            "Selector at(index) requires an integer argument, got [#{index}] (#{index.class})"
    end

    # Selects first element in input
    #
    # @example Select first value in an array
    #   rule = Remap::Compiler.call do
    #     map :names, first, to: :name
    #   end
    #
    #   state = Remap::State.call({
    #     names: ["John", "Jane"]
    #   })
    #
    #   output = rule.call(state) do |failure|
    #     raise failure.exception
    #   end
    #
    #   output.fetch(:value) # => { name: "John" }
    #
    # @return [Path::Segment::Key]]
    def first
      if block_given?
        raise ArgumentError, "first selector does not take a block"
      end

      at(0)
    end
    alias any first

    # Selects last element in input
    #
    # @example Select last value in an array
    #   rule = Remap::Compiler.call do
    #     map :names, last, to: :name
    #   end
    #
    #   state = Remap::State.call({
    #     names: ["John", "Jane", "Linus"]
    #   })
    #
    #   output = rule.call(state) do |failure|
    #     raise failure.exception
    #   end
    #
    #   output.fetch(:value) # => { name: "Linus" }
    #
    # @return [Path::Segment::Key]
    def last
      if block_given?
        raise ArgumentError, "last selector does not take a block"
      end

      at(-1)
    end

    private

    def add(rule)
      rule.tap { rules << rule }
    end

    def rule(*path, to: EMPTY_ARRAY, backtrace: caller, &block)
      Rule::Map::Required.call({
        path: {
          output: [to].flatten,
          input: path.flatten
        },
        backtrace: backtrace,
        rule: call(backtrace: backtrace, &block)
      })
    end

    def rule?(*path, to: EMPTY_ARRAY, backtrace: caller, &block)
      Rule::Map::Optional.call({
        path: {
          output: [to].flatten,
          input: path.flatten
        },
        rule: call(backtrace: backtrace, &block)
      })
    end
  end
end
