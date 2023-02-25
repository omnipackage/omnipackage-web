# frozen_string_literal: true

::FactoryBot.define do
  factory :agent do
    apikey { ::Faker::Internet.password }
  end
end
