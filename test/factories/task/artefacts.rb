# frozen_string_literal: true

::FactoryBot.define do
  factory :task_artefact, class: '::Task::Artefact' do
    task { association :task }
    distro { ::Distro.all.sample.id }
  end
end
