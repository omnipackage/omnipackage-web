# frozen_string_literal: true

::FactoryBot.define do
  factory :task_artefact, class: '::Task::Artefact' do
    task { association :task }
    distro { ::Distro.by_package_type('rpm').sample.id }
    attachment { ::Rack::Test::UploadedFile.new(::Rails.root.join('test/fixtures/files/sample_project-1.3.5-1.x86_64.rpm'), 'application/x-rpm') }
  end
end
