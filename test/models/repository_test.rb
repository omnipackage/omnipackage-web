# frozen_string_literal: true

require 'test_helper'

class RepositoryTest < ::ActiveSupport::TestCase
  test 'valid factory' do
    assert build(:repository).valid?
    assert build(:repository, distro_id: 'ololo').invalid?
    assert build(:repository, bucket: '87362LKJGLUTo87tgol982(*Y^*&^').invalid?
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
