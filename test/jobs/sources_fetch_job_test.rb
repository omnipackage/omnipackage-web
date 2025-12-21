require 'test_helper'

class SourcesFetchJobTest < ::ActiveJob::TestCase
  include ::ActiveJob::TestHelper

  test 'fetch and store tarball' do
    o = create(:project_sources_tarball)
    original_timestamp = o.updated_at
    ::SourcesFetchJob.perform_now(o.project_id)

    assert_operator o.reload.updated_at, :>, original_timestamp
  end
end
