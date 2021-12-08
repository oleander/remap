# frozen_string_literal: true

module Remap
  module State
    module Extension
      using Extensions::Enumerable
      using Extensions::Object
      using Extensions::Hash

      refine Hash do
        # Returns a list of all key paths
        #
        # @example Get paths
        #   {
        #     a: {
        #       b: :c
        #     },
        #     d: :e
        #   }.paths # => [[:a, :b], [:d]]
        #
        # @return [Array<Array<Symbol>>] a list of key paths
        def paths
          reduce(EMPTY_ARRAY) do |acc, (path, leaves)|
            if (paths = leaves.paths).empty?
              next acc + [[path]]
            end

            acc + paths.map { |inner| [path] + inner }
          end
        end

        # Restrict hash to passed key path
        #
        # @param key [Symbol] to be kept
        # @param rest [Array<Symbol>] of the key path
        #
        # @example Select key path
        #   {
        #     a: {
        #       b: :c
        #     },
        #     d: :e
        #   }.only(:a, :b) # => { a: { b: :c } }
        #
        # @returns [Hash] a hash containing the given path
        # @raise Europace::Error when path doesn't exist
        def only(*path)
          path.reduce(EMPTY_HASH) do |hash, key|
            next hash unless key?(key)

            hash.deep_merge(key => fetch(key))
          end
        end

        # Throws :fatal containing a Notice
        def fatal!(...)
          throw :fatal, notice(...)
        end

        # Throws :warn containing a Notice
        def notice!(...)
          throw :notice, notice(...)
        end

        # Throws :ignore containing a Notice
        def ignore!(...)
          throw :ignore, notice(...)
        end

        # Creates a notice containing the given message
        #
        # @param template [String]
        # @param values [Array]
        #
        # @return [Notice]
        def notice(template, *values)
          Notice.call(only(:value, :path).merge(reason: template % values))
        end

        # Validates {self} against {Schema}
        #
        # Only used during development
        #
        # @yield [Hash] if schema fails
        #
        # @raise if schema fails and no block is given
        #
        # @return [self]
        def _(&block)
          unless block
            return _ { raise ArgumentError, "Input: #{self} output: #{_1.formatted}" }
          end

          unless (result = Schema.call(self)).success?
            return block[result.errors.to_h]
          end

          self
        end

        # Makes the state iterable
        #
        # @yieldparam value [Any]
        # @yieldoption key [Symbol]
        # @yieldoption index [Integer]
        #
        # @yieldreturn [State]
        #
        # @return [State]
        def map(&block)
          bind do |value, state|
            Iteration.call(state: state, value: value).call do |other, **options|
              state.set(other, **options).then(&block)
            end.except(:index, :element, :key)
          end
        end

        # @return [String]
        def inspect
          "#<State %s>" % compact_blank.formatted
        end

        # Merges {self} with {other} and returns a new state
        #
        # @param other [State]
        #
        # @return [State]
        def combine(other)
          deep_merge(other) do |key, value1, value2|
            case [key, value1, value2]
            in [:value, Array => list1, Array => list2]
              list1 + list2
            in [:value, left, right]
              fatal!(
                "Could not merge [%p] (%s) with [%p] (%s) @ %s",
                left,
                left.class,
                right,
                right.class,
                (path + [key]).join("."))
            in [:notices, Array => n1, Array => n2]
              n1 + n2
            in [Symbol, _, value]
              value
            end
          end
        end

        # Creates a new state with params
        #
        # @param value [Any, Undefined] Used as {value:}
        # @options [Hash] To be combine into {self}
        #
        # @return [State]
        def set(value = Undefined, **options)
          if value != Undefined
            return set(**options, value: value)
          end

          case [self, options]
          in [{notices:}, {notice: notice, **rest}]
            merge(notices: notices + [notice]).set(**rest)
          in [{value:}, {mapper:, **rest}]
            merge(scope: value, mapper: mapper).set(**rest)
          in [{path:}, {key:, **rest}]
            merge(path: path + [key], key: key).set(**rest)
          in [{path:}, {index:, value:, **rest}]
            merge(path: path + [index], element: value, index: index, value: value).set(**rest)
          in [{path:}, {index:, **rest}]
            merge(path: path + [index], index: index).set(**rest)
          else
            merge(options)
          end
        end

        # Passes {#value} to block, if defined
        # The return value is then wrapped in a state
        # and returned with {options} combine into the state
        #
        # @yieldparam value [T]
        # @yieldparam self [State]
        # @yieldparam error [Proc]
        #
        # @yieldreturn [Y]
        #
        # @return [State<Y>]
        def fmap(**options, &block)
          bind(**options) do |input, state, &error|
            state.set(block[input, state, &error])
          end
        end

        # Creates a failure to be used in {Remap::Base} & {Remap::Mapper}
        #
        # @param reason [#to_s]
        #
        # @see State::Schema
        #
        # @return [Failure]

        # class Failure < Dry::Interface
        #   attribute :notices, [Notice], min_size: 1
        # end

        def failure(reason = Undefined)
          failures = case [path, reason]
          in [_, Notice => notice]
            [notice]
          in [path, Array => reasons]
            reasons.map do |inner_reason|
              Notice.call(path: path, reason: inner_reason, **only(:value))
            end
          in [path, String => reason]
            [Notice.call(path: path, reason: reason, **only(:value))]
          in [path, Hash => errors]
            errors.paths.flat_map do |sufix|
              Array.wrap(errors.dig(*sufix)).map do |inner_reason|
                Notice.call(
                  reason: inner_reason,
                  path: path + sufix,
                  **only(:value))
              end
            end
          end

          Failure.new(failures: failures, notices: notices)
        end

        # Passes {#value} to block, if defined
        # {options} are combine into the final state
        #
        # @yieldparam value [T]
        # @yieldparam self [State]
        # @yieldparam error [Proc]
        #
        # @yieldreturn [Y]
        #
        # @return [Y]
        def bind(**options, &block)
          unless block_given?
            raise ArgumentError, "State#bind requires a block"
          end

          fetch(:value) { return self }.then do |value|
            block[value, self] do |reason, **other|
              return set(**options, **other).notice!(reason)
            end
          end
        end

        # Execute {block} in the current context
        # Only calls {block} if {#value} is defined
        #
        # @yieldparam [T]
        # @yieldreturn [U]
        #
        # @return [State<U>]
        def execute(&block)
          bind do |value, &error|
            result = context(value, &error).instance_exec(value, &block)

            if result.equal?(Dry::Core::Constants::Undefined)
              return error["Undefined returned, skipping!"]
            end

            set(result)._
          rescue KeyError, IndexError => e
            error[e.message]
          rescue PathError => e
            ignore!("Path %s not defined for %p (%s)", e.path.join("."), value, value.class)
          end
        end

        # Passes {#value} to block and returns {self}
        #
        # @return [self]
        def tap(&block)
          super { fmap(&block) }
        end

        # A list of keys representing the path to {#value}
        #
        # @return [Array<Symbol, Integer, String>]
        def path
          fetch(:path, EMPTY_ARRAY)
        end

        # Represents options to a mapper
        #
        # @see Rule::Embed
        #
        # @return [Hash]
        def options
          fetch(:options)
        end

        # Used by {#context} to create a limited context
        #
        # @return [Hash]
        def to_hash
          super.except(:options, :notices, :value)
        end

        # @return [Any]
        def value
          fetch(:value)
        end

        # @return [Integer]
        def index
          fetch(:index)
        end

        # @return [Any]
        def element
          fetch(:element)
        end

        # @return [Any]
        def key
          fetch(:key)
        end

        # @return [Array<Notice>]
        def notices
          fetch(:notices)
        end

        private

        # Creates a context containing {options} and {self}
        #
        # @param value [Any]
        #
        # @yieldparam reason [T]
        #
        # @return [Struct]
        def context(value, context: self, &error)
          ::Struct.new(*keys, *options.keys, :state, keyword_init: true) do
            define_method :method_missing do |name, *|
              error["Method [#{name}] not defined"]
            end

            define_method :skip! do |message = "Manual skip!"|
              context.ignore!(message)
            end
          end.new(**to_hash, **options, value: value, state: self)
        end
      end
    end
  end
end
