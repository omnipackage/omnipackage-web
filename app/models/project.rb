# frozen_string_literal: true

class Project < ::ApplicationRecord
  belongs_to :user

  enum sources_kind: %w[git].index_with(&:itself), _default: 'git'

  attribute :name, :string, default: ''
  attribute :sources_location, :string, default: ''
  attribute :sources_ssh_key, :string, default: ''

  validates :name, presence: true, length: { in: 2..150 }
  validates :sources_location, presence: true, length: { in: 2..8000 }
  validates :sources_kind, presence: true

  def sources
    ::Project::Sources.new(kind: sources_kind, location: sources_location)
  end

  def sources_verified?
    sources_verified_at.present?
  end

  def sources_verified!
    update!(sources_verified_at: ::Time.now.utc)
  end

  def sources_unverified!
    update!(sources_verified_at: nil)
  end
end
