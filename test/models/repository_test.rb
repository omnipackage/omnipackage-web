# frozen_string_literal: true

require 'test_helper'

class RepositoryTest < ::ActiveSupport::TestCase
  test 'valid factory' do
    assert build(:repository).valid?
    assert build(:repository, distro_id: 'ololo').invalid?
  end
end
