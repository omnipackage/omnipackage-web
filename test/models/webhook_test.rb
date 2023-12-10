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
  end
end
