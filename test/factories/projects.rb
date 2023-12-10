# frozen_string_literal: true

::FactoryBot.define do
  factory :project do
    name { ::Faker::Artist.name }
    sources_kind { ::Project.sources_kinds.keys.sample }
    sources_location { ::Faker::Internet.url }
    user

    factory :project_with_sources do
      sources_tarball { association :project_sources_tarball }
    end
  end
end
