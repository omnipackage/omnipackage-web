# frozen_string_literal: true

require 'test_helper'

class UserTest < ::ActiveSupport::TestCase
  test 'factory and validation' do
    o = create(:user)
    assert o.valid?
    assert o.gpg_key.pub.present? && o.gpg_key.priv.present?
    assert_match(/-----BEGIN PGP PRIVATE KEY BLOCK-----/, o.gpg_key.priv)
    assert_match(/-----BEGIN PGP PUBLIC KEY BLOCK-----/, o.gpg_key.pub)
  end
end
