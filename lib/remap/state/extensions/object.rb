module Remap
  module State
    module Extensions
      module Object
        refine ::Object do
          def _(&block)
            unless block
              return _ { raise _1 }
            end

            block["Expected a state, got [#{self}] (#{self.class})"]
          end

          def paths
            EMPTY_ARRAY
          end

          def get(*path)
            throw :missing, path
          end
        end
      end
    end
  end
end
