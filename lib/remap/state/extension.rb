# frozen_string_literal: true

module Remap
  module State
    # @api private
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
          dup.extract!(*path)
        end

        # @see #notice
        def fatal!(...)
          fatal_id = fetch(:fatal_id) do
            raise ArgumentError, "Missing :fatal_id in %s" % formatted
          end

          throw fatal_id, Failure.new(failures: [notice(...)], notices: notices)
        end

        # @see #notice
        def ignore!(...)
          set(notice: notice(...)).except(:value).return!
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
          return self unless mapper.validate?

          unless block
            return _ do |reason|
              raise ArgumentError, "[BUG] State: #{formatted} reason: #{reason.formatted}"
            end
          end

          unless (result = Schema.call(self)).success?
            return block[result.errors.to_h]
          end

          self
        end

        # Iterates over {#value}
        #
        # @yieldparam value [Any]
        # @yieldparam key [Symbol]
        # @yieldparam index [Integer]
        #
        # @yieldreturn [State]
        #
        # @return [State]
        def map(&block)
          result = case self
          in { value: Array => array }
            array.each_with_index.each_with_object([]) do |(value, index), array|
              s1 = block[set(value, index: index)]

              if s1.key?(:value)
                array << s1[:value]
              end
            end
          in { value: Hash => hash }
            hash.each_with_object({}) do |(key, value), acc|
              s1 = block[set(value, key: key)]

              if s1.key?(:value)
                acc[key] = s1[:value]
              end
            end
          in { value: }
            fatal!("Expected an enumerable got %s", value.class)
          else
            return self
          end

          set(result)
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
          merge(other) do |key, value1, value2|
            case [key, value1, value2]
            in [_, Hash => left, Hash => right]
              left.merge(right)
            in [:ids | :fatal_ids, _, right]
              right
            in [_, Array => left, Array => right]
              left + right
            in [:value, left, right]
              other.fatal!(
                "Could not merge [%s] (%s) with [%s] (%s)",
                left.formatted,
                left.class,
                right.formatted,
                right.class
              )
            in [Symbol, _, value]
              value
            end
          end._
        end

        # @todo Merge with {#remove_fatal_id}
        # @return [State]
        def remove_id
          state = dup

          case state
          in { ids: [], id: }
            state.except!(:id)
          in { ids:, id: }
            state.merge!(ids: ids[1...], id: ids[0])
          in { ids: [] }
            state
          in { ids: }
            raise ArgumentError, "[BUG] #ids for state are set, but not #id: %s" % formatted
          end

          state
        end

        # @todo Merge with {#remove_id}
        # @return [State]
        def remove_fatal_id
          state = dup

          case state
          in { fatal_ids: [], fatal_id: }
            state.except!(:fatal_id)
          in { fatal_ids: ids, fatal_id: }
            state.merge!(fatal_ids: ids[1...], fatal_id: ids[0])
          in { fatal_ids: [] }
            state
          in { fatal_ids: }
            raise ArgumentError, "[BUG] #ids for state are set, but not #id: %s" % formatted
          end

          state
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

          state = dup

          case [state, options]
          in [{notices:}, {notice: notice}]
            state.merge!(notices: notices + [notice])
          in [{value:}, {mapper:}]
            state.merge!(scope: value, mapper: mapper)
          in [{path: p1}, {path: p2}]
            state.merge!(path: p1 + p2)
          in [{path:}, {key:, value:}]
            state.merge!(path: path + [key], key: key, value: value)
          in [{path:}, {key:}]
            state.merge!(path: path + [key], key: key)
          in [{path:}, {index:, value:}]
            state.merge!(path: path + [index], element: value, index: index, value: value)
          in [{path:}, {index:}]
            state.merge!(path: path + [index], index: index)
          in [{ids:, id: old_id}, {id: new_id}]
            state.merge!(ids: [old_id] + ids, id: new_id)
          in [{fatal_ids:, fatal_id: old_id}, {fatal_id: new_id}]
            state.merge!(fatal_ids: [old_id] + fatal_ids, fatal_id: new_id)
          else
            state.merge!(options)
          end

          state
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
          bind(**options) do |input, state:|
            state.set(block[input, state, state: state])
          end
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
          unless block
            raise ArgumentError, "State#bind requires a block"
          end

          s1 = set(**options)

          fetch(:value) { return s1 }.then do |value|
            block[value, s1, state: s1]
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
          value = fetch(:value) { return self }

          path = catch :ignore do
            names = block.parameters.reduce([]) do |acc, (type, name)|
              case type
              in :keyreq
                acc + [name]
              else
                acc
              end
            end

            n1 = options.only(*names)
            n2 = only(*names)

            result = block[value, **n2, **n1] do |reason|
              return ignore!(reason)
            end

            return set(result)
          end

          set(path: path).ignore!("Undefined path")
        rescue KeyError => e
          set(path: [e.key]).ignore!(e.message)
        rescue IndexError => e
          ignore!(e.message)
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

        # @return [Symbol]
        def id
          fetch(:id)
        end

        # @return [Mapper::API]
        def mapper
          fetch(:mapper)
        end

        # @return [Array<Symbol>]
        def ids
          fetch(:ids)
        end

        # @return [Symbol]
        def fatal_id
          fetch(:fatal_id)
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
          super.except(:options, :notices, :value, :id, :ids, :fatal_id, :fatal_ids)
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

        # Creates a failure from the current state
        #
        # @param reason [String, Hash, Undefined]
        #
        # @return [Failure]
        def failure(reason = Undefined)
          failures = case [path, reason]
          in [_, Undefined]
            return Failure.new(failures: notices)
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
                  **only(:value)
                )
              end
            end
          end

          Failure.new(failures: failures, notices: notices)
        end

        # @raise [ArgumentError]
        #   when {#id} is not defined
        #
        # @private
        def return!
          id = fetch(:id) do
            raise ArgumentError, "#id not defined for state [%s]" % [formatted]
          end

          throw id, remove_id
        end
      end
    end
  end
end
