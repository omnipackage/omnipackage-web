# frozen_string_literal: true

::FactoryBot.define do
  factory :task do
    sources_tarball { association :project_sources_tarball }
  end
end
