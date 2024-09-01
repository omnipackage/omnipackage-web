# frozen_string_literal: true

class PublicApplicationController < ::ApplicationController
  skip_before_action :require_authentication
  layout 'public'
end
