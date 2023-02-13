# frozen_string_literal: true

class ApplicationMailer < ::ActionMailer::Base
  default from: 'support@omnipackage.org'
  layout 'mailer'
end
