# frozen_string_literal: true

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
    ::ShellUtil.shred(priv_keyfilepath) unless ::Rails.env.local?
    ::FileUtils.remove_entry(dir)
  end

  private

  def execute(*cli)
    ::ShellUtil.execute(*cli, env: env, timeout_sec: 10)
  end
end
