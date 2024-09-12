# frozen_string_literal: true

require 'test_helper'

class Task
  class LogTest < ::ActiveSupport::TestCase
    test 'append text' do
      task = create(:task)

      task.append_log("hello\n")
      task.append_log('successfully finished build for opensuse_tumbleweed in 10s...')
      task.append_log('successfully finished build for debian_11 in 10s...')
      task.append_log('failed build for debian_12 in 10s...')
      task.append_log("world\n")

      assert_equal "hello\nsuccessfully finished build for opensuse_tumbleweed in 10s...successfully finished build for debian_11 in 10s...failed build for debian_12 in 10s...world\n", task.log.reload.text
      assert_equal %w[debian_11 opensuse_tumbleweed], task.progress.done
      assert_equal %w[debian_12], task.progress.failed
    end
  end
end
