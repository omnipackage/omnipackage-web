# frozen_string_literal: true

require 'test_helper'

class Task
  class ArtefactTest < ::ActiveSupport::TestCase
    test 'factory' do
      assert build(:task_artefact).valid?
    end
  end
end
