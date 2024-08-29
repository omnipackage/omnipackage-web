# frozen_string_literal: true

class ApplicationRecord < ::ActiveRecord::Base
  primary_abstract_class

  extend ::Broadcasts::BaseBroadcast::AR

  protected

  def max_len_validator_on(attribute)
    self.class.validators_on(attribute).find { _1.is_a?(::ActiveRecord::Validations::LengthValidator) }.options.fetch(:maximum)
  end
end
