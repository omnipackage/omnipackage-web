# frozen_string_literal: true

require 'open3'

class Git
  attr_reader :exe, :env

  def initialize(exe: 'git', env: {})
    @exe = exe
    @env = { 'SSH_ASKPASS' => '', 'GIT_ASKPASS' => '' }.merge(env)
    # "GIT_SSH_COMMAND='ssh -i #{keyfile} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'"
  end

  def ping(repo)
    execute(exe, 'ls-remote', '--exit-code', '-h', repo, timeout_sec: 8).success?
  end

  private

  def execute(*cli, timeout_sec: 30) # rubocop: disable Metrics/MethodLength
    stdin, stdout_and_stderr, wait_thr = ::Open3.popen2e(env, *cli)

    begin
      ::Timeout.timeout(timeout_sec) do
        wait_thr.join
      end
    rescue ::Timeout::Error
      ::Process.kill('KILL', wait_thr.pid)
    end

    stdin.close
    stdout_and_stderr.close

    wait_thr.value
  end
end
