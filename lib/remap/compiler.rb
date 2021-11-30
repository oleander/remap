# frozen_string_literal: true

module Remap
  # Constructs a {Rule} from the block passed to {Remap::Base.define}
  class Compiler < Proxy
    include Dry::Core::Constants

    param :rules, default: -> { EMPTY_ARRAY.dup }

    # @return [Rule]
    delegate :call, to: Compiler

    # Constructs a rule tree given {block}
    #
    # @return [Rule]
    def self.call(&block)
      unless block
        return Rule::Void.new
      end

      compiler = new
      compiler.instance_exec(&block)
      compiler.rule
    end

    # Maps {path} to {to} with {block} inbetween
    #
    # @param path ([]) [Array<Segment>, Segment]
    # @param to ([]) [Array<Symbol>, Symbol]
    #
    # @return [Rule::Map]
    def map(*path, to: EMPTY_ARRAY, &block)
      add Rule::Map.new(
        path: { output: [to].flatten, input: path.flatten },
        rule: call(&block)
      )
    end

    # Maps using {mapper}
    #
    # @param mapper [Remap]
    #
    # @return [Rule::Embed]
    def embed(mapper)
      add Rule::Embed.new(mapper: mapper)
    rescue Dry::Struct::Error
      raise ArgumentError, "Embeded mapper must be [Remap::Mapper], got [#{mapper}]"
    end

    # @param *path ([]) [Symbol, Array<Symbol>]
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

    # Maps to {path} from {map} with {block} inbetween
    #
    # @param path [Array<Symbol>, Symbol]
    # @param map [Array<Segment>, Segment]
    #
    # @return [Rule::Map]
    def to(*path, map: EMPTY_ARRAY, &block)
      map(*map, to: path, &block)
    end

    # Iterates over the input value, passes each value
    # to its block and merges the result back together
    #
    # @return [Rule::Each]]
    # @raise [ArgumentError] if no block given
    def each(&block)
      unless block
        raise ArgumentError, "no block given"
      end

      add Rule::Each.new(rule: call(&block))
    end

    # Wraps output in {type}
    #
    # @param type [:array]
    #
    # @yieldreturn [Rule]
    #
    # @return [Rule::Wrap]
    # @raise [ArgumentError] if type is not :array
    def wrap(type, &block)
      unless block
        raise ArgumentError, "no block given"
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
    def option(id)
      Static::Option.new(name: id)
    end

    # Selects {index} element in input
    #
    # @param index [Integer]
    #
    # @return [Path::Segment::Key]
    # @raise [ArgumentError] if index is not an Integer
    def at(index)
      Selector::Index.new(index: index)
    rescue Dry::Struct::Error
      raise ArgumentError, "Selector at(index) requires an integer argument, got [#{index}] (#{index.class})"
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
