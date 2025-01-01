::FactoryBot.define do
  factory :project_sources_tarball, class: '::Project::SourcesTarball' do
    transient do
      location { ::Rails.root.join('test/fixtures/sample_project') }
      envelop { ::Project::Sources.new(kind: 'localfs', location: location.to_s).sync }
    end

    tarball { ::ActiveStorage::Blob.create_and_upload!(io: envelop.tarball, filename: '123.tar.xz') }
    config { envelop.config }
    project { association :project, sources_kind: 'localfs', sources_location: location.to_s }
  end
end
