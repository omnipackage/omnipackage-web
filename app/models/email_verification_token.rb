# frozen_string_literal: true

class EmailVerificationToken < ::ApplicationRecord
  belongs_to :user, class_name: '::User'
end
