# frozen_string_literal: true

class ProjectDistro < ::ApplicationRecord
  belongs_to :project

  attribute :distro_id, :string, default: ''

  validates :distro_id, presence: true, inclusion: { in: ::Distro.all.map(&:id) }

  def distro
    ::Distro[distro_id]
  end
end
