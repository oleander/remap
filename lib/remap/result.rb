# frozen_string_literal: true

module Remap
  class Result < Dry::Struct
    attribute :problems, Types.Array(Types::Problem)

    def has_problem?
      !problems.blank?
    end
  end
end
