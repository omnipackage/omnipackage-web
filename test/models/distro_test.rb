# frozen_string_literal: true

require 'test_helper'

class DistroTest < ::ActiveSupport::TestCase
  test 'all distros valid' do
    assert ::Distro.all.size.positive?
    ::Distro.all.each do |d| # rubocop: disable Rails/FindEach
      assert d.id.is_a?(::String)
      assert d.name.is_a?(::String)
      assert d.setup.is_a?(::Array)
      assert d.setup.size.positive?
      assert %w[rpm deb].include?(d.package_type) # rubocop: disable Performance/CollectionLiteralInLoop
      d.setup.each do |s|
        assert s.is_a?(::String)
      end
    end
  end
end
