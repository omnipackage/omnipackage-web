# frozen_string_literal: true

class Gpg
  Key = ::Data.define(:priv, :pub) do
    def private_id
      ::Gpg.new.key_id(priv)
    end

    def public_info
      ::Gpg.new.key_info(pub)
    end
  end

  attr_reader :exe

  def initialize(exe: 'gpg')
    @exe = exe
  end

  def generate_keys(name, email) # rubocop: disable Metrics/AbcSize
    within_tmp_dir do |dir, env|
      batchfile_path = ::Pathname.new(dir).join('genkey.batch')
      write_file(batchfile_path, batch_generate_keys(name, email))

      ::ShellUtil.execute(exe, '--no-tty', '--batch', '--gen-key', batchfile_path.to_s, env: env, chdir: dir).success!
      pubkey = ::ShellUtil.execute(exe, '--armor', '--export', name, env: env, chdir: dir).success!.out
      privkey = ::ShellUtil.execute(exe, '--armor', '--export-secret-keys', name, env: env, chdir: dir).success!.out
      Key[privkey, pubkey]
    end
  end

  def key_id(key_string)
    ::ShellUtil.execute("#{exe} --show-keys <<HERE
#{key_string}
HERE").success!.out.lines[1].strip
  end

  def key_info(key_string)
    ::ShellUtil.execute("#{exe} --show-keys --with-fingerprint <<HERE
#{key_string}
HERE").success!.out
  end

  private

  def write_file(path, content)
    ::File.open(path, 'w') do |file|
      file.write(content)
    end
  end

  def within_tmp_dir
    ::Dir.mktmpdir do |dir|
      env = { 'GNUPGHOME' => dir }
      yield(dir, env)
    end
  end

  def batch_generate_keys(name, email)
    <<~SCRIPT
Key-Type: RSA
Key-Length: 4096
Name-Real: #{name}
Name-Email: #{email}
Expire-Date: 0
%no-ask-passphrase
%no-protection
%commit
    SCRIPT
  end
end
