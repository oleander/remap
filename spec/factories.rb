# frozen_string_literal: true

require "faker"

using Remap::State::Extension
include Dry::Core::Constants

FactoryBot.define do
  initialize_with { new(attributes) }

  sequence(:key_path, aliases: [:path]) { Array.new(2).map { FactoryBot.generate(:key) } }
  sequence(:integer, aliases: [:index]) { Faker::Number.number(digits: 2) }
  sequence(:key) { "key_#{Faker::Lorem.word.underscore}".to_sym }
  sequence(:value, aliases: [:values, :input]) { |n| "value#{n}" }
  sequence(:class_name) { Faker::Lorem.word.camelize }

  factory Remap::Base, aliases: [:mapper, Remap::Base] do
    initialize_with do |context: self|
      Dry::Core::ClassBuilder.new(name: name, parent: Remap::Base).call do |klass|
        klass.class_eval do
          context.options.each_key do |name|
            option name
          end
        end
      end
    end

    transient do
      name { [generate(:class_name), "Mapper"].join }
      options { EMPTY_HASH }
    end
  end

  factory Remap::Rule::Map, aliases: [Remap::Rule::Map] do
    input_path { input }
    output_path { output }

    transient do
      input { generate(:path) }
      output { generate(:path) }
    end
  end

  factory "Remap::Static::Option", aliases: [Remap::Static::Option, "static/option"] do
    initialize_with { new(attributes) }

    name { generate(:key) }
  end

  factory "Remap::Static::Fixed", aliases: ["static/fixed", Remap::Static::Fixed] do
    value
  end

  factory Remap::Rule::Void, aliases: [Remap::Rule::Void] do
    # NOP
  end

  factory :problem, class: Hash do
    initialize_with { Remap::Types::Problem[attributes] }

    reason { Faker::Lorem.sentence }
    path
    value
  end

  factory :state, class: Hash, aliases: [:undefined] do
    initialize_with { attributes }

    problems { EMPTY_ARRAY }
    options { EMPTY_HASH }
    values { input }

    mapper
    path
    input

    factory :defined do
      value
    end

    factory :element do
      value
      index
    end

    trait :with_problems do
      problems { build_list(:problem, 1) }
    end
  end
end
