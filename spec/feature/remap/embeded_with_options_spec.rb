# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class, password: "secret" do
    let(:computer) do
      mapper! do
        option :password

        define do
          set :password, to: option(:password)
        end
      end
    end

    let(:mapper) do |context: self|
      mapper! do
        define do
          to :computer do
            embed context.computer
          end
        end
      end
    end

    let(:input) { {} }

    let(:output) do
      {
        computer: {
          password: "secret"
        }
      }
    end
  end
end
