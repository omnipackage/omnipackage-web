# frozen_string_literal: true

class Git
  attr_reader :exe, :ssh_exe, :global_env, :ssh_private_key

  def initialize(exe: 'git', ssh_exe: 'ssh', env: {}, ssh_private_key: '')
    @exe = exe
    @ssh_exe = ssh_exe
    @ssh_private_key = ssh_private_key
    @global_env = {
      'SSH_ASKPASS' => '',
      'GIT_ASKPASS' => ''
    }.merge(env)
  end

  def ping(repo)
    with_ssh_key do |env|
      ::ShellUtil.execute(exe, 'ls-remote', '--exit-code', '-h', repo, env: env, timeout_sec: 8).success?
    end
  end

  def clone(repo, destination)
    with_ssh_key do |env|
      ::ShellUtil.execute(exe, 'clone', '--depth', '1', repo, destination, env: env, timeout_sec: 300).success!
    end
  end

  private

  def with_ssh_key
    keyfile = ::Tempfile.new
    keyfile.write(ssh_private_key)
    keyfile.close
    env = global_env.merge(
      'GIT_SSH_COMMAND' => "#{ssh_exe} -i #{keyfile.path} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
    )
    yield(env)
  ensure
    ::FileUtils.remove_entry_secure(keyfile.path)
  end
end
