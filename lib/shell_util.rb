# frozen_string_literal: true

require 'open3'

module ShellUtil
  module_function

  def execute_wo_io(*cli, env: {}, timeout_sec: 30) # rubocop: disable Metrics/MethodLength
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

  def shred(filepath)
    filesize = ::File.size(filepath)
    [0xFF, 0xAA, 0x55, 0x00].each do |byte|
      ::File.open(filepath, 'wb') do |f|
        filesize.times { f.print(byte.chr) }
      end
    end
  end
end
