# frozen_string_literal: true

::FactoryBot.define do
  factory :repository do
    project { association :project }
    distro_id { ::Distro.all.sample.id }
    bucket { ::Faker::Address.city }
    endpoint { nil }
    access_key_id { nil }
    secret_access_key { nil }
    region { nil }
  end
end
