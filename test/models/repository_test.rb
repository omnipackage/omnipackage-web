require 'test_helper'

class RepositoryTest < ::ActiveSupport::TestCase
  test 'valid factory' do
    assert_predicate build(:repository), :valid?
    assert_predicate build(:repository, distro_id: 'ololo'), :invalid?
  end

  test 'gpg keys' do
    repo = create(:repository)

    assert_not repo.with_own_gpg_key?

    gpg = ::Gpg.new.generate_keys(::Faker::Internet.username, ::Faker::Internet.email)
    repo.gpg_key_private = gpg.priv
    repo.gpg_key_public = gpg.pub
    repo.save

    assert_match(/-----BEGIN PGP PRIVATE KEY BLOCK-----/, repo.gpg_key_private)
    assert_match(/-----BEGIN PGP PUBLIC KEY BLOCK-----/, repo.gpg_key_public)
  end
end
