# frozen_string_literal: true

::FactoryBot.define do
  factory :project_sources_tarball, class: ::Project::SourcesTarball do
    transient do
      location { ::Rails.root.join('test/fixtures/sample_project') }
      envelop { ::Project::Sources.new(kind: 'localfs', location: location.to_s).sync }
    end

    tarball { envelop.tarball }
    config { envelop.config }
    project { association :project, sources_kind: 'localfs', sources_location: location.to_s }
  end
end
