::FactoryBot.define do
  factory :project do
    name { ::Faker::Artist.unique.name }
    sources_kind { ::Project.sources_kinds.keys.sample }
    sources_location { ::Faker::Internet.unique.url }
    user

    factory :project_with_sources do
      sources_tarball { association :project_sources_tarball, location: ::Rails.root.join('test/fixtures/sample_project') }
      sources_kind { 'localfs' }
      sources_location { ::Rails.root.join('test/fixtures/sample_project') }
    end
  end
end
