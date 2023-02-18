# frozen_string_literal: true

class Project < ::ApplicationRecord
  belongs_to :user

  attribute :name, :string, default: ''

  validates :name, presence: true, length: { in: 2..150 }
end
