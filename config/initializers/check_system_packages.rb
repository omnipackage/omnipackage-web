['tar', 'gpg', 'xz', { 'ssh-keygen' => 'ssh -V' }, ::APP_SETTINGS.fetch(:container_runtime), 'git', 'flock', 'tree'].each do |b|
  name, cmd = if b.is_a?(::Hash)
                [b.keys.first, b.values.first]
              else
                [b, "#{b} --version"]
              end
  raise "please install #{name}" unless system("#{cmd} >/dev/null 2>&1")
end
