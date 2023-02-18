# frozen_string_literal: true

require 'test_helper'

class ProjectDistroTest < ::ActiveSupport::TestCase
  test 'validations' do
    assert build(:project_distro).valid?
    assert build(:project_distro).project.valid?
  end
end
