# frozen_string_literal: true

require 'test_helper'

class InboundWebhooksFlowTest < ::ActionDispatch::IntegrationTest
  test 'trigger' do
    webhook = create(:webhook, project: create(:project_with_sources))
    assert_equal 0, webhook.project.tasks.count
    post trigger_webhook_path_path(webhook.key)
    assert_equal 200, status
    assert_equal 1, webhook.project.tasks.count
  end

  test 'with github signature' do
    webhook = create(:webhook, project: create(:project_with_sources), secret: "It's a Secret to Everybody")
    assert_equal 0, webhook.project.tasks.count

    post trigger_webhook_path_path(webhook.key), headers: { 'X-Hub-Signature-256' => 'sha256=66a0c074deaa0f489ead6537e0d32f9a344b90bbeda705b6ed45ecd3b413fb40' }
    assert_equal 200, status
    assert_equal 1, webhook.project.tasks.count

    post trigger_webhook_path_path(webhook.key), headers: { 'X-Hub-Signature-256' => 'sha256=nope' }
    assert_equal 401, status
    assert_equal 1, webhook.project.tasks.count

    post trigger_webhook_path_path(webhook.key)
    assert_equal 401, status
    assert_equal 1, webhook.project.tasks.count
  end
end
