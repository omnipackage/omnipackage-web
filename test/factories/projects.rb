# frozen_string_literal: true

::FactoryBot.define do
  factory :project do
    name { ::Faker::Artist.name }
    sources_kind { ::Project.sources_kinds.keys.sample }
    sources_location { ::Faker::Internet.url }
    user
  end
end
