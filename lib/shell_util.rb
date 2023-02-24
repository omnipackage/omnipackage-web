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

  def compress_and_encrypt(source_dir, passphrase:, excludes: [], env: {})
    sap [env, 'tar', *excludes.map { |e| "--exclude=#{e}" }, '-C', source_dir, '-cJf', '-', '.']
    sap [env, 'gpg', '-c', '--passphrase', passphrase, '--batch', '--yes']
    last_stdout, _wait_threads = ::Open3.pipeline_r(
      [env, 'tar', *excludes.map { |e| "--exclude=#{e}" }, '-C', source_dir, '-cJf', '-', '.'],
      [env, 'gpg', '-c', '--passphrase', passphrase, '--batch', '--yes']
    )
    last_stdout.binmode
    last_stdout.read
  end

  def decrypt(input, passphrase:, env: {})
    first_stdin, last_stdout, _wait_threads = ::Open3.pipeline_rw(
      [env, 'gpg', '-d', '--passphrase', passphrase, '--batch', '--yes']
      # [env, 'tar', '-xvJf', '-']
    )
    first_stdin.binmode
    first_stdin.write(input)
    first_stdin.close
    last_stdout.read
  end

  def decompress(input, destination_path, env: {})
    first_stdin, _wait_threads = ::Open3.pipeline_w(
      [env, 'tar', '--directory', destination_path, '-xJf', '-']
    )
    first_stdin.binmode
    first_stdin.write(input)
    first_stdin.close
    destination_path
  end
end
