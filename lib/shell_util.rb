# frozen_string_literal: true

require 'open3'

module ShellUtil
  module_function

  class ShellError < ::StandardError; end
  ShellResult = ::Data.define(:exitcode, :out, :err, :cli) do
    delegate :success?, to: :exitcode

    def success!
      return self if success?

      raise ShellError, "`#{cli.join(' ').strip}` error: (#{exitcode}) #{err.presence || out}"
    end
  end

  def execute(*cli, chdir: ::Dir.pwd, env: {}, timeout_sec: 30) # rubocop: disable Metrics/MethodLength
    stdin, stdout, stderr, wait_thr = ::Open3.popen3(env, *cli, chdir: chdir)

    begin
      ::Timeout.timeout(timeout_sec) do
        wait_thr.join
      end
    rescue ::Timeout::Error
      ::Process.kill('KILL', wait_thr.pid)
    end

    ShellResult[wait_thr.value, stdout.read, stderr.read, cli]
  ensure
    stdin.close
    stdout.close
    stderr.close
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
    last_stdout, wait_threads = ::Open3.pipeline_r(
      [env, 'tar', *excludes.map { |e| "--exclude=#{e}" }, '-C', source_dir, '-cJf', '-', '.'],
      [env, 'gpg', '-c', '--passphrase', passphrase, '--batch', '--yes', '--quiet']
    )
    last_stdout.binmode
    wait_threads.each(&:join)
    last_stdout.read
  end

  def decrypt(input, passphrase:, env: {})
    first_stdin, last_stdout, wait_threads = ::Open3.pipeline_rw(
      [env, 'gpg', '-d', '--passphrase', passphrase, '--batch', '--yes', '--quiet']
      # [env, 'tar', '-xvJf', '-']
    )
    first_stdin.binmode
    first_stdin.write(input)
    first_stdin.close
    wait_threads.each(&:join)
    last_stdout.read
  end

  def decompress(input, destination_path, env: {})
    first_stdin, wait_threads = ::Open3.pipeline_w(
      [env, 'tar', '--directory', destination_path, '-xJf', '-']
    )
    first_stdin.binmode
    first_stdin.write(input)
    first_stdin.close
    wait_threads.each(&:join)
    destination_path
  end
end
