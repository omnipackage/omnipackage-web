# frozen_string_literal: true

require 'open3'

class Git
  attr_reader :exe, :env

  def initialize(exe: 'git', env: {})
    @exe = exe
    @env = { 'SSH_ASKPASS' => '', 'GIT_ASKPASS' => '' }.merge(env)
  end

  def ping(repo)
    execute(*[exe, 'ls-remote', '--exit-code', '-h', repo]).success?
  end

  private

  def execute(*cli, timeout_sec: 5, &block)
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
