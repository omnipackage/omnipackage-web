# frozen_string_literal: true

::FactoryBot.define do
  factory :project do
    name { ::Faker::Artist.name }
    user
  end
end
