# frozen_string_literal:true

describe Remap::Base do
  it_behaves_like described_class do
    let(:mapper) do
      mapper! do
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

          to(:customer) do
            to(:of_legal_age) do
              map [:applicants] do
                each do
                  map(:birth_date).then { (2020 - ::Time.parse(value).to_date.year) >= 18 }
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
    end

    let(:input) do
      {
        id: 42,
        applicants: [
          { last_name: "Mustermann", birth_date: "2000-01-01" }
        ],
        financing_plan: {
          objects_costs: [{ building: 500_000.0 }]
        },
        financial_data: {
          incomes: [
            { label: "Gehalt Antragsteller", value: 5000.0, number_of_rates: 12 },
            { label: "Nebentätigkeit Antragsteller", value: 500.0, number_of_rates: 12 }
          ]
        },
        offer: { reason: "PURCHASE" },
        status: "ok"
      }
    end

    let(:output) do
      be_a_success.and(
        have_attributes({
          result: {
            id: 42,
            object: { costs: [500_000.0] },
            reason: "Kauf",
            customer: {
              of_legal_age: [true],
              name: "Mustermann",
              income: 5500.0
            }
          }
        })
      )
    end
  end
end
