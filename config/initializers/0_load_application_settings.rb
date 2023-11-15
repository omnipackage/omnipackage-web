# frozen_string_literal: true

def load_application_settings
  path = ::Rails.root.join('config/application_settings.yml')
  content = ::File.read(path)
  yaml = ::ERB.new(content).result
  ::YAML.load(yaml, aliases: true).fetch(::Rails.env).with_indifferent_access.freeze
end

APP_SETTINGS = load_application_settings
