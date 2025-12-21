require 'test_helper'

class DistroTest < ::ActiveSupport::TestCase
  test 'all distros valid' do
    assert_predicate ::Distro.all.size, :positive?
    ::Distro.all.each do |d| # rubocop: disable Rails/FindEach
      assert_kind_of ::String, d.id
      assert_kind_of ::String, d.name
      assert_kind_of ::Array, d.setup
      assert_predicate d.setup.size, :positive?
      assert_includes %w[rpm deb], d.package_type
      d.setup.each do |s|
        assert_kind_of ::String, s
      end
    end
  end
end
