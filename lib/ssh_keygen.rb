# frozen_string_literal: true

require 'open3'

class SshKeygen
  Key = ::Data.define(:priv, :pub)

  attr_reader :exe, :env

  def initialize(exe: 'ssh-keygen', env: {})
    @exe = exe
    @env = env
  end

  def generate(comment: 'omnipackage')
    dir = ::Dir.mktmpdir
    keyfilename = ::SecureRandom.hex
    priv_keyfilepath = ::File.join(dir, keyfilename)
    pub_keyfilepath = ::File.join(dir, keyfilename + '.pub')

    if execute(exe, '-f', priv_keyfilepath, '-N', '', '-q', '-t', 'rsa', '-b', '4096', '-C', comment).success?
      Key[::File.read(priv_keyfilepath), ::File.read(pub_keyfilepath)]
    end
  ensure
    shred(priv_keyfilepath) unless ::Rails.env.local?
    ::FileUtils.remove_entry(dir)
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

  def shred(filepath)
    filesize = ::File.size(filepath)
    [0xFF, 0xAA, 0x55, 0x00].each do |byte|
      ::File.open(filepath, 'wb') do |f|
        filesize.times { f.print(byte.chr) }
      end
    end
  end
end
