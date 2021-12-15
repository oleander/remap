# frozen_string_literal: true

require "faker"

using Remap::State::Extension

FactoryBot.define do
  initialize_with { new(attributes) }

  sequence(:key_path, aliases: [:path]) do
    Array.new(2).map do
      FactoryBot.generate(:key)
    end
  end
  sequence(:symbol) { |n| :"symbol_#{n}" }

  sequence(:integer, aliases: [:index]) { Faker::Number.number(digits: 2) }
  sequence(:key) { "key_#{Faker::Lorem.word.underscore}".to_sym }
  sequence(:value, aliases: [:values, :input]) { |n| "value#{n}" }
  sequence(:class_name) { Faker::Lorem.word.camelize }

  factory Remap::Base, aliases: [:mapper, Remap::Base] do
    initialize_with do |context: self|
      Dry::Core::ClassBuilder.new(name: name,
                                  parent: Remap::Base).call do |klass|
        klass.class_eval do
          context.options.each_key do |name|
            option name
          end
        end
      end
    end

    transient do
      name { [generate(:class_name), "Mapper"].join }
      options { {} }
    end
  end

  factory Remap::Rule::Map, aliases: [Remap::Rule::Map] do
    path { { input: input, output: output } }
    backtrace { ["<backtrace>"] }

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

  factory :notice, class: "Remap::Notice" do
    reason { "this is a reason" }
    path { generate(:path) }
    value { generate(:value) }
  end

  factory :state, class: Hash, aliases: [:undefined] do
    initialize_with { attributes }

    failures { [] }
    notices { [] }
    options { {} }
    values { input }
    path { [] }
    ids { [] }
    fatal_ids { [] }

    mapper
    input

    factory :defined do
      value
    end

    factory :element do
      value
      index
    end

    trait :with_notices do
      notices { build_list(:notice, 1) }
    end

    trait :with_failures do
      failures { build_list(:notice, 1) }
    end

    trait :with_path do
      path { [generate(:path)] }
    end

    trait :with_fatal_id do
      fatal_id { [generate(:symbol), "fatal_id"].join("_").to_sym }
    end
  end
end
