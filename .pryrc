# frozen_string_literal: true

if ::Rails.env.development?
  include ::FactoryBot::Syntax::Methods
end

def me
  ::User.find_by(email: 'oleg.b.antonyan@gmail.com')
end

def formatted_env
  if ::Rails.env.production?
    bold_env = ::Pry::Helpers::Text.bold(::Rails.env.upcase)
    ::Pry::Helpers::Text.red(bold_env)
  elsif ::Rails.env.development?
    ::Pry::Helpers::Text.green(::Rails.env.upcase[0, 3])
  else
    ::Pry::Helpers::Text.yellow(::Rails.env.upcase)
  end
end
::Pry::Prompt.add "project_custom", "Includes the current Rails environment.", %w[> *] do |target_self, nest_level, _pry, sep|
  "[#{formatted_env}] (#{::Pry.view_clip(target_self)}) #{'>' * nest_level}#{sep} "
end
::Pry.config.prompt = ::Pry::Prompt.all["project_custom"]
