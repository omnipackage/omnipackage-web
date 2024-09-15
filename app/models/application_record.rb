# frozen_string_literal: true

class ApplicationRecord < ::ActiveRecord::Base
  primary_abstract_class

  extend ::Broadcasts::BaseBroadcast::AR
  extend ::RemovableHasOneAttached
end
