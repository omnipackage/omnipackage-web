# frozen_string_literal: true

['tar', 'gpg', 'xz', 'git', { 'ssh-keygen' => 'ssh -V' }].each do |b|
  name, cmd = if b.is_a?(::Hash)
                [b.keys.first, b.values.first]
              else
                [b, "#{b} --version"]
              end
  raise "please install #{name}" unless system("#{cmd} &> /dev/null")
end
