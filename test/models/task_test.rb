# frozen_string_literal: true

require 'test_helper'

class TaskTest < ::ActiveSupport::TestCase
  test 'factory and validation' do
    o = create(:task)
    assert o.valid?
    assert o.sources_tarball.valid?
    assert o.state == 'fresh'
    assert_equal o.project, o.sources_tarball.project

    assert build(:task, sources_tarball: nil).invalid?
  end
end
