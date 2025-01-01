class ApplicationPublicController < ::ApplicationController
  skip_before_action :require_authentication
  skip_before_action :authenticate

  layout 'public'
end
