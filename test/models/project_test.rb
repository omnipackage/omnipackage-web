require 'test_helper'

class ProjectTest < ::ActiveSupport::TestCase
  test 'validations' do
    assert build(:project).valid?
    assert build(:project, name: '').invalid?
    assert build(:project, name: nil).invalid?
  end
end
