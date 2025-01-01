::FactoryBot.define do
  factory :webhook do
    key { ::Faker::Internet.password }
    secret { nil }
    project { association :project }
  end
end
