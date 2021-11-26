# frozen_string_literal: true

require "faker"

using Remap::State::Extension

FactoryBot.define do
  initialize_with { new(attributes) }

  # sequence of array
  sequence(:key_path) { Array.new(2).map { FactoryBot.generate(:key) } }
  sequence(:hash) { Faker::Types.complex_rb_hash(number: 1) }
  sequence(:value, aliases: [:values]) { |n| "value#{n}" }
  sequence(:string) { Faker::Types.rb_string }
  sequence(:integer, aliases: [:index]) { Faker::Number.number(digits: 2) }
  sequence(:float) { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
  sequence(:boolean) { Faker::Boolean.boolean }
  sequence(:date) { Faker::Date.between(from: Date.today - 1.year, to: Date.today) }
  sequence(:time) { Faker::Time.between(from: Date.today - 1.year, to: Date.today) }
  sequence(:datetime) { Faker::Time.between(from: Date.today - 1.year, to: Date.today) }
  sequence(:decimal) { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
  sequence(:uuid) { Faker::Internet.uuid }
  sequence(:email) { Faker::Internet.email }
  sequence(:url) { Faker::Internet.url }
  sequence(:ip_v4) { Faker::Internet.ip_v4_address }
  sequence(:mac_address) { Faker::Internet.mac_address }
  sequence(:slug) { Faker::Lorem.word }
  sequence(:username) { Faker::Internet.username }
  sequence(:password) { Faker::Internet.password }
  sequence(:word) { Faker::Lorem.word }
  sequence(:sentence) { Faker::Lorem.sentence }
  sequence(:paragraph) { Faker::Lorem.paragraph }
  sequence(:sentences) { Faker::Lorem.sentences }
  sequence(:paragraphs) { Faker::Lorem.paragraphs }
  sequence(:name) { Faker::Name.name }
  sequence(:first_name) { Faker::Name.first_name }
  sequence(:last_name) { Faker::Name.last_name }
  sequence(:title) { Faker::Job.title }
  sequence(:phone_number) { Faker::PhoneNumber.phone_number }
  sequence(:street_address) { Faker::Address.street_address }
  sequence(:city) { Faker::Address.city }
  sequence(:state) { Faker::Address.state }
  sequence(:zip) { Faker::Address.zip }
  sequence(:country) { Faker::Address.country }
  sequence(:latitude) { Faker::Address.latitude }
  sequence(:longitude) { Faker::Address.longitude }
  sequence(:street_name) { Faker::Address.street_name }
  sequence(:city_prefix) { Faker::Address.city_prefix }
  sequence(:city_suffix) { Faker::Address.city_suffix }
  sequence(:class_name) { Faker::Lorem.word.camelize }
  sequence(:key) { "key_#{Faker::Lorem.word.underscore}".to_sym }

  factory Remap::Base, aliases: [:mapper, Remap::Base] do
    initialize_with do |context: self|
      Dry::Core::ClassBuilder.new(name: name, parent: Remap::Base).call do |klass|
        klass.class_eval do
          context.options.each_key do |name|
            option name
          end

          # define do
          #   map
          # end
        end
      end
    end

    transient do
      name { "#{generate(:class_name)}Mapper" }
      options { {} }
    end
  end

  factory Remap::Rule::Path, aliases: [Remap::Rule::Path] do
    map { input }
    to { output }

    transient do
      input { generate(:key_path) }
      output { generate(:key_path) }
    end
  end

  factory Remap::Rule::Map, aliases: [Remap::Rule::Map] do
    path { build(Remap::Rule::Path) }
    rule { build(Remap::Rule::Void) }

    transient do
      input { [:input] }
      output { [:output] }
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

  factory :state, class: Hash do
    initialize_with { attributes }

    options { {} }
    problems { {} }
    input { {} }
    values { input }
    path { [] }
    mapper

    factory :undefined do
      # NOP
    end

    factory :defined do
      value { 1 }
    end

    factory :element do
      value { "value" }
      index { 1 }
    end

    trait :with_problems do
      sequence(:problems) { |n| generate(:key_path).hide("Reason #{n}") }
    end
  end
end
