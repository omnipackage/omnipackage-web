# frozen_string_literal: true

class Agent < ::ApplicationRecord
  encrypts :apikey, deterministic: true

  validates :apikey, presence: true, uniqueness: true
end
