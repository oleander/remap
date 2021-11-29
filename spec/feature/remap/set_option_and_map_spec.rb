# frozen_string_literal: true

describe Remap::Base do
  it_behaves_like described_class, key: "12345" do
    let(:mapper) do
      mapper! do
        option :key

        define do
          map :data, to: :payload
          to :config do
            set :api_key, to: option(:key)
            set :environment, to: value("production")
          end
        end
      end
    end

    let(:input) { { data: { key: "value" } } }

    let(:output) do
      be_a_success.and(have_attributes(result: { payload: { key: "value" },
                                                 config: { api_key: "12345", environment: "production" } }))
    end
  end
end
