# frozen_string_literal: true

require 'test_helper'

class AgentTest < ::ActiveSupport::TestCase
  test 'validation' do
    assert build(:agent).valid?
    assert build(:agent, apikey: '').invalid?
    assert build(:agent, apikey: nil).invalid?
  end
end
