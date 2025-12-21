require 'test_helper'

class Task
  class ArtefactTest < ::ActiveSupport::TestCase
    test 'factory' do
      assert_predicate build(:task_artefact), :valid?
    end
  end
end
