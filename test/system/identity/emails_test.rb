require 'application_system_test_case'

module Identity
  class EmailsTest < ::ApplicationSystemTestCase
    setup do
      @user = sign_in_as(create(:user))
      visit identity_account_path
    end

    test 'updating the email' do
      click_on 'Change email address'

      fill_in 'New email', with: 'new_email@hey.com'
      click_on 'Save changes'

      assert_text 'Your email has been changed'
    end

    test 'sending a verification email' do
      @user.update!(verified_at: nil)

      click_on 'Change email address'
      click_on 'Re-send verification email'

      assert_text 'We sent a verification email to your email address'
    end
  end
end
