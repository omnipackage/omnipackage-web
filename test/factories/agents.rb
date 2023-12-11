# frozen_string_literal: true

::FactoryBot.define do
  factory :agent do
    name { ::Faker::Movie.title }
    arch { 'x86_64' }
  end
end
