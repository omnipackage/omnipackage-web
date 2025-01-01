url_options = {
  production: { host: 'omnipackage.org' }
}
url_options.default = { host: 'localhost', port: 5000 }

::Rails.application.configure do
  config.action_mailer.default_url_options = url_options[::Rails.env.to_sym]
end

unless ::Rails.env.test? # system tests fail otherwise
  ::Rails.application.routes.default_url_options = url_options[::Rails.env.to_sym]
end
