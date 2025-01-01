::FactoryBot.define do
  factory :task do
    transient do
      location { ::Rails.root.join('test/fixtures/sample_project') }
      envelop { ::Project::Sources.new(kind: 'localfs', location: location.to_s).sync }
    end

    project { association :project }
    sources { ::ActiveStorage::Blob.create_and_upload!(io: envelop.tarball, filename: '123.tar.xz') }
  end
end
