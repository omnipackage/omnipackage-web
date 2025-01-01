::FactoryBot.define do
  factory :agent do
    name { ::Faker::Movie.unique.title }
    arch { 'x86_64' }
  end
end
