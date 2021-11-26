# frozen_string_literal: true

require "bundler/setup"
Bundler.require

input = JSON.parse(Pathname(__FILE__).dirname.join("input.json").read).deep_symbolize_keys
output = JSON.parse(Pathname(__FILE__).dirname.join("output.json").read).deep_symbolize_keys

class Fixed < Remap::Base
  define do
    map :id, to: :id
    to(:object, :costs) do
      map [:financing_plan, :objects_costs] do
        each do
          map(:building).if do
            input.dig(:offer, :reason) == "PURCHASE"
          end
        end
      end
    end

    to(:"main-customer") do
      to(:of_legal_age) do
        map [:applicants] do
          each do
            map(:birth_date).then do
              (2020 - ::Time.parse(value).to_date.year) >= 18
            end
          end
        end
      end

      to(:name) do
        map(:applicants, any, :last_name)
      end

      to(:income) do
        map(:financial_data, :incomes).then do
          value.select { |v| v.fetch(:label).include?("Antragsteller") }
               .map { |v| v.fetch(:value) }
               .collect
               .sum
        end
      end
    end

    map(:offer, :reason, to: :reason).enum do
      from "PURCHASE", to: "Kauf"
    end
  end
end

pp input

pp Fixed.call(input)
# .fmap do |result|
#   pp result

#   puts "-------------"

#   pp output

#   puts "-------"

#   puts result == output
# end
