# frozen_string_literal: true

require 'open3'

class Git
  attr_reader :exe, :env

  def initialize(exe: 'git', ssh_exe: 'ssh', env: {}, ssh_private_key: '')
    @exe = exe
    @ssh_private_key_file = ::Tempfile.new
    ssh_private_key_file.write(ssh_private_key)
    ssh_private_key_file.close
    @env = {
      'SSH_ASKPASS' => '',
      'GIT_ASKPASS' => '',
      'GIT_SSH_COMMAND' => "#{ssh_exe} -i #{ssh_private_key_file.path} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
    }.merge(env)
  end

  def ping(repo)
    ::ShellUtil.execute_wo_io(exe, 'ls-remote', '--exit-code', '-h', repo, env: env, timeout_sec: 8).success?
  ensure
    remove_private_key_file
  end

  private

  attr_reader :ssh_private_key_file

  def remove_private_key_file
    ::ShellUtil.shred(ssh_private_key_file.path)
    ssh_private_key_file.unlink
  end
end
