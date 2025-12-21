require 'test_helper'

class AgentTest < ::ActiveSupport::TestCase
  test 'validation' do
    assert_predicate build(:agent), :valid?
    assert_predicate build(:agent, apikey: ''), :invalid?
  end
end
