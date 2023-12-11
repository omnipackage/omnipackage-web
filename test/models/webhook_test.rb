# frozen_string_literal: true

require 'test_helper'

class WebhookTest < ::ActiveSupport::TestCase
  test 'validations' do
    assert build(:webhook).valid?
    assert build(:webhook, key: nil).invalid?
    assert build(:webhook, project: nil).invalid?
  end

  test 'verify signature github' do
    wh = build(:webhook, secret: "It's a Secret to Everybody")

    assert wh.verify_github("Hello, World!", "sha256=757107ea0eb2509fc211221cce984b8a37570b6d7586c22c46f4379c8b043e17")
    assert_not wh.verify_github("Hello, World!", "NOPE")
    assert_not wh.verify_github("Hello, World!", "757107ea0eb2509fc211221cce984b8a37570b6d7586c22c46f4379c8b043e17")

    assert_equal ['X-Hub-Signature-256', 'sha256=66a0c074deaa0f489ead6537e0d32f9a344b90bbeda705b6ed45ecd3b413fb40'], wh.sample_header_github
  end
end
