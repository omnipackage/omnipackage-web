# frozen_string_literal: true

::FactoryBot.define do
  factory :agent do
    apikey { ::Faker::Internet.password }
    name { ::Faker::Movie.title }
    arch { 'x86_64' }
  end
end
