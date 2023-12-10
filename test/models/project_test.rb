# frozen_string_literal: true

require 'test_helper'

class ProjectTest < ::ActiveSupport::TestCase
  test 'validations' do
    assert build(:project).valid?
    assert build(:project, name: '').invalid?
    assert build(:project, name: nil).invalid?
    assert build(:project, name: 'превед').invalid?
    assert build(:project, name: ';№"5куыцфмыjhg').invalid?
    assert build(:project, name: 'olo 123 sdf   sdaf').valid?
    assert build(:project, sources_location: nil).invalid?
    assert build(:project, sources_kind: nil).invalid?
    assert_raises(::ArgumentError) do
      build(:project, sources_kind: :ololo)
    end
    assert build(:project, sources_kind: :git).valid?
    assert build(:project, sources_kind: 'git').valid?
    assert build(:project, sources_subdir: '/../etc/').invalid?
    assert build(:project, sources_subdir: '../etc/passwd').invalid?
    assert build(:project, sources_subdir: '../../..etc/passwd').invalid?
    assert build(:project, sources_subdir: '/').invalid?
    assert build(:project, sources_subdir: '/etc').invalid?
    assert build(:project, sources_subdir: 'test/sample_project').valid?
    assert build(:project, sources_tarball: build(:project_sources_tarball)).sources_tarball.valid?
  end

  test 'generate ssh keys' do
    project = build(:project)
    assert project.generate_ssh_keys
    assert project.sources_private_ssh_key
    assert project.sources_public_ssh_key
    assert_match(/-----BEGIN OPENSSH PRIVATE KEY-----/, project.sources_private_ssh_key)
  end

  test 'safe name' do
    assert_equal 'proj__12_gfd', build(:project, name: 'ProJ  12 gfd').safe_name
  end
end
