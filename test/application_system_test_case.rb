# frozen_string_literal: true

require 'test_helper'

class ApplicationSystemTestCase < ::ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]

  def sign_in_as(user)
    visit sign_in_url
    fill_in :email, with: user.email
    fill_in :password, with: 'Secret1*3*5*'
    find('input[name="commit"]').click

    assert_current_path root_url
    assert_text user.email # navbar
    assert page.has_css?('.alert-success', text: 'Signed in successfully')
    user
  end
end
