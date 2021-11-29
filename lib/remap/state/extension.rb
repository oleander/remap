# frozen_string_literal: true

require "active_support/core_ext/hash/deep_transform_values"

module Remap
  module State
    module Extension
      using Extensions::Enumerable
      using Extensions::Object

      refine Hash do
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
            return _ { raise "Input: #{self} output: #{JSON.pretty_generate(_1)}" }
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
              state.set(other, **options)._.then(&block)._
            end
          end
        end

        # @return [String]
        def inspect
          reject { |_, value| value.blank? }.then do |cleaned|
            format("#<State %<json>s>", json: JSON.pretty_generate(cleaned))
          end
        end

        # Merges {self} with {other} and returns a new state
        #
        # @param other [State]
        #
        # @return [State]
        def merged(other)
          all_problems = problems + other.problems

          catch :undefined do
            value = recursive_merge(other) do |reason|
              return merge(problems: all_problems).problem(reason)
            end

            return set(value, problems: all_problems)
          end

          set(problems: all_problems)
        end

        # Resolves conflicts unsovable by ActiveSupport#deep_merge
        #
        # @param key [Symbol] the key that cannot be merged
        # @param left [Any] the left value that cannot be merged
        # @param right [Any] the right value that cannot be merged
        #
        # @yieldparam reason [String] if {left} and {right} cannot be merged
        # @yieldreturn [State]
        #
        # @return [Any]
        def conflicts(key, left, right, &error)
          case [left, right]
          in [Array, Array]
            left + right
          in [value, ^value]
            value
          in [left, right]
            reason(left, right) do |reason|
              [reason, "[#{key}]"].join(" @ ").then(&error)
            end
          end
        end

        # Recursively merges {self} with {other}
        # Invokes {error} when a conflict is detected
        #
        # @param other [State]
        #
        # @yieldparam key [Symbol]
        # @yieldparam left [Any]
        # @yieldparam right [Any]
        # @yieldparam error [Proc]
        #
        # @yieldreturn [Any]
        #
        # @return [Any] Merge result (not a state)
        def recursive_merge(other, &error)
          case [self, other]
          in [{value: Hash => left}, {value: Hash => right}]
            left.deep_merge(right) { |*args| conflicts(*args, &error) }
          in [{value: Array => left}, {value: Array => right}]
            left + right
          in [{value: left}, {value: right}]
            reason(left, right, &error)
          in [{value: left}, _]
            left
          in [_, {value: right}]
            right
          in [_, _]
            throw :undefined
          end
        end

        def reason(left, right, &error)
          params = { left: left, cleft: left.class, right: right, cright: right.class }
          message = format("Could not merge [%<left>p] (%<cleft>s) with [%<right>p] (%<cright>s)", params)
          error[message]
        end

        # Creates a new state with params
        #
        # @param value [Any, Undefined] Used as {value:}
        # @options [Hash] To be merged into {self}
        #
        # @return [State]
        def set(value = Undefined, **options)
          if value != Undefined
            return set(**options, value: value)
          end

          case [self, options]
          in [{path:}, {quantifier:, **rest}]
            merge(path: path + [quantifier]).set(**rest)
          in [_, {mapper:, value:, **rest}]
            merge(scope: value, value: value, mapper: mapper).set(**rest)
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
        # and returned with {options} merged into the state
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

        # Creates a single problem / failure
        #
        # @param reason [#to_s]
        #
        # @see State::Schema
        #
        # @return [Hash]
        def failure(reason)
          case [path, reason]
          in [EMPTY_ARRAY, Array | String => message]
            { base: Array.wrap(message) }
          in [path, String | Array => message]
            path.hide(Array.wrap(message))
          in [path, Hash => failures]
            path.hide(failures)
          end
        end

        def explaination(reason, explainations = EMPTY_HASH)
          Remap::Types::Report::Self[explainations]

          report = ->(message) { [{}.merge(reason: message)] }

          explaination = case [self, reason]
          in [{path: []}, String]
            { base: report[reason] }
          in [{path:}, String]
            path.hide(report[reason])
          in [{path:}, Hash]
            reason.paths_pair.reduce(EMPTY_HASH) do |acc, (item, suffix)|
              Array.wrap(item).map { (path + suffix).hide(report[_1]) }.reduce(acc, &:deep_merge)
            end
          end

          explainations.deep_merge(explaination) do |key, left, right|
            case [left, right]
            in [Array, Array]
              left + right
            else
              raise ArgumentError, "Cannot merge #{left} with #{right} @ #{key}"
            end
          end
        end

        # Number of current problems
        # Mainly used for debugging
        #
        # @return [Integer]
        def no_of_problems
          problems.count
        end

        # Passes {#value} to block, if defined
        # {options} are merged into the final state
        #
        # @yieldparam value [T]
        # @yieldparam self [State]
        # @yieldparam error [Proc]
        #
        # @yieldreturn [Y]
        #
        # @return [Y]
        def bind(**options, &block)
          unless block
            raise ArgumentError, "no block given"
          end

          fetch(:value) { return self }.then do |value|
            block[value, self] do |reason, **other|
              return set(**options, **other).problem(reason)._
            end
          end
        end

        # Execute {block} in the current context
        # Only calls {block} if {#value} is defined
        #
        # @yieldparam value [T]
        # @yieldreturn [U]
        #
        # @return [State<U>]
        def execute(&block)
          bind do |value, &error|
            catch :success do
              path = catch :missing do
                throw :success, set(context(value, &error).instance_exec(value, &block))._
              end

              return error["Could not fetch value at", path: path]
            end
          rescue NoMethodError => e
            e.name == :fetch ? error["Fetch not defined on value: #{e}"] : raise
          rescue NameError => e
            e.name == :Undefined ? error["Undefined returned, skipping!: #{e}"] : raise
          rescue KeyError, IndexError => e
            error[e.message]
          end
        end

        # Passes {#value} to block and returns {self}
        #
        # @return [self]
        def tap(&block)
          super { fmap(&block) }
        end

        # Ensures {value:} is not a state
        #
        # @param options [Hash]
        #
        # @return [Hash]
        def merge(options)
          case options
          in {value:}
            value._ { return super }
          else
            return super
          end

          raise ArgumentError, "Expected State#value not to be a State [#{value}] (#{value.class})"
        end

        def to_hash
          except(:options, :mapper, :problems, :value)
        end

        def value
          fetch(:value)
        end

        # Returns a new state that includes a new problem
        #
        # Removes {#value} as problems cannot contain values
        #
        # @param message [#to_s]
        #
        # @return [State]
        def problem(message)
          problem = { reason: message.to_s, path: path, value: dig(:value) }.reject do |_, value|
            value.blank?
          end

          Remap::Types::Problem[problem]

          merge(problems: problems + [problem]).except(:value)
        end

        # A list of problems
        #
        # @see State::Schema
        #
        # @return [Hash]
        def problems
          fetch(:problems)
        end

        # A list of keys representing the path to {#value}
        #
        # @return [Array<Symbol, Integer, String>]
        def path
          fetch(:path)
        end

        def options
          fetch(:options)
        end

        # Creates a context containing {options} and {self}
        #
        # @param value [Any]
        #
        # @yieldparam reason [T]
        #
        # @return [Struct]
        def context(value, &error)
          ::Struct.new(*keys, *options.keys, keyword_init: true) do
            define_method :method_missing do |name, *|
              error["Method [#{name}] not defined"]
            end

            define_method :skip! do |message = "Manual skip!"|
              error[message]
            end
          end.new(**to_hash, **options, value: value)
        end
      end
    end
  end
end
