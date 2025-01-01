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

  def test_key(key) # rubocop: disable Metrics/AbcSize, Metrics/MethodLength
    within_tmp_dir do |dir, env|
      ::ShellUtil.execute(exe, '--import', env: env, chdir: dir, timeout_sec: 1) do |stdin|
        stdin.write(key.priv)
        stdin.close
      end.success!

      ::ShellUtil.execute(exe, '--import', env: env, chdir: dir, timeout_sec: 1) do |stdin|
        stdin.write(key.pub)
        stdin.close
      end.success!

      ::ShellUtil.execute(exe, '-o', '/dev/null', '-as', '-', env: env, chdir: dir, timeout_sec: 1) do |stdin|
        stdin.write('random string to encrypt')
        stdin.close
      end.success!
    end
  end

  private

  def write_file(path, content)
    ::File.open(path, 'w') do |file|
      file.write(content)
    end
  end

  def within_tmp_dir
    dir = ::Dir.mktmpdir
    env = { 'GNUPGHOME' => dir }
    yield(dir, env)
  ensure
    ::FileUtils.remove_entry_secure(dir)
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
