# frozen_string_literal: true

['tar', 'gpg', 'xz', 'git', { 'ssh' => 'ssh -V' }].each do |b|
  ok = if b.is_a?(::Hash)
         system("#{b.keys.first} #{b.values.first} &> /dev/null")
       else
         system("#{b} --version &> /dev/null")
       end
  raise "please install #{b}" unless ok
end
