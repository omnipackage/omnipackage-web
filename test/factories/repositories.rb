::FactoryBot.define do
  factory :repository do
    project { association :project }
    distro_id { ::Distro.all_active.sample.id }
    gpg_key_private { nil }
    gpg_key_public { nil }
  end
end
