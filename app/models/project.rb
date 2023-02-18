# frozen_string_literal: true

class Project < ::ApplicationRecord
  belongs_to :user
  has_many :project_distros, dependent: :destroy

  attribute :name, :string, default: ''

  validates :name, presence: true, length: { in: 2..150 }

  def distros
    ::Distro.by_ids(project_distros.pluck('distro_id'))
  end
end
