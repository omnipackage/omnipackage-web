require 'test_helper'

class AgentTest < ::ActiveSupport::TestCase
  test 'validation' do
    assert build(:agent).valid?
    assert build(:agent, apikey: '').invalid?
  end
end
