# frozen_string_literal: true

if ::Rails.env.development?
  include ::FactoryBot::Syntax::Methods
end

if ::Rails.env.production?
  ::Pry.config.prompt = ::Pry::Prompt[:rails]
end

def me
  ::User.find_by(email: 'oleg.b.antonyan@gmail.com')
end
