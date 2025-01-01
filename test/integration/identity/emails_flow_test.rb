require 'test_helper'

module Identity
  class EmailsFlowTest < ::ActionDispatch::IntegrationTest
    setup do
      @user = sign_in_as(create(:user))
    end

    test 'should get edit' do
      get edit_identity_email_url
      assert_response :success
    end

    test 'should update email' do
      patch identity_email_url, params: { email: 'new_email@hey.com' }
      assert_redirected_to root_url
    end
  end
end
