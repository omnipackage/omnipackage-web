# frozen_string_literal: true

include ::FactoryBot::Syntax::Methods

# Pry.config.prompt = Pry::Prompt[:rails]

def me
  ::User.find_by(email: 'oleg.b.antonyan@gmail.com')
end
