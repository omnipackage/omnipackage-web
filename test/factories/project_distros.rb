# frozen_string_literal: true

::FactoryBot.define do
  factory :project_distro do
    project
    distro_id { ::Distro.all.sample.id }
  end
end
