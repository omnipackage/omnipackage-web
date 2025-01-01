APP_SETTINGS = begin
  path = ::Rails.root.join('config/application_settings.yml')
  content = ::File.read(path)
  yaml = ::ERB.new(content).result
  ::YAML.load(yaml, aliases: true).fetch(::Rails.env).with_indifferent_access.freeze
end
