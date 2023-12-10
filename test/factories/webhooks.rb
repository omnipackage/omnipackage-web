# frozen_string_literal: true

::FactoryBot.define do
  factory :webhook do
    key { ::Faker::Internet.password }
    secret { nil }
    project { association :project }
  end
end
