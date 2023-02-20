# frozen_string_literal: true

require 'test_helper'

class ProjectTest < ::ActiveSupport::TestCase
  test 'validations' do
    assert build(:project).valid?
    assert build(:project, name: '').invalid?
    assert build(:project, name: nil).invalid?
    assert build(:project, sources_location: nil).invalid?
    assert build(:project, sources_kind: nil).invalid?
    assert_raises(::ArgumentError) do
      build(:project, sources_kind: :ololo)
    end
    assert build(:project, sources_kind: :git).valid?
    assert build(:project, sources_kind: 'git').valid?
  end
end
