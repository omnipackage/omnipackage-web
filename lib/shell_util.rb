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

  def execute(*cli, chdir: ::Dir.pwd, env: {}, timeout_sec: 30, term_timeout_sec: 10) # rubocop: disable Metrics/MethodLength, Metrics/AbcSize
    stdin, stdout, stderr, wait_thr = ::Open3.popen3(env, *cli, chdir: chdir)

    begin
      ::Timeout.timeout(timeout_sec) do
        yield(stdin) if block_given?
        wait_thr.join
      end
    rescue ::Timeout::Error
      ::Process.kill('TERM', wait_thr.pid)
      begin
        ::Timeout.timeout(term_timeout_sec) do
          wait_thr.join
        end
      rescue ::Timeout::Error
        ::Process.kill('KILL', wait_thr.pid)
      end
    end

    ShellResult[wait_thr.value, stdout.read, stderr.read, cli]
  ensure
    stdin.close
    stdout.close
    stderr.close
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

  def compress(source_dir, destination_file, excludes: [], env: {})
    last_stdout, wait_threads = ::Open3.pipeline_r(
      [env, 'tar', '-C', source_dir, '-cJf', destination_file, *excludes.map { |e| "--exclude=#{e}" }, '.']
    )
    last_stdout.binmode
    wait_threads.each(&:join)
    destination_file
  end
end
