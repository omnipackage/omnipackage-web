# frozen_string_literal: true

ApplicationSettings = ::YAML.load_file(::Rails.root.join('config/application_settings.yml'), aliases: true).fetch(::Rails.env).with_indifferent_access.freeze
