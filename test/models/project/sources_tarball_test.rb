# frozen_string_literal: true

require 'test_helper'

class Project
  class SourcesTarballTest < ::ActiveSupport::TestCase
    test 'factory and storage' do
      sources_location = ::Rails.root.join('test/fixtures/sample_project')

      o = build(:project_sources_tarball, location: sources_location)

      assert o.tarball
      assert o.config

      tmpdir = ::Dir.mktmpdir
      begin
        ::ShellUtil.decompress(o.decrypted_tarball, tmpdir)

        extracted = ::Dir.glob(tmpdir + '/**/*')
        assert_equal ::Dir.glob(sources_location.to_s + '/**/*').size, extracted.size

        assert_equal ::File.read(sources_location.join('.omnipackage/config.yml')), ::File.read("#{tmpdir}/.omnipackage/config.yml")

        extracted.each do |fp|
          src_file = ::Rails.root.join(sources_location, fp.remove(tmpdir + '/'))
          assert_equal ::File.read(src_file), ::File.read(fp)
        end
      ensure
        ::FileUtils.remove_entry(tmpdir)
      end
    end
  end
end
