# frozen_string_literal: true

class Repository < ::ApplicationRecord
  belongs_to :project

  validates :distro_id, inclusion: { in: ::Distro.ids }

  def distro
    ::Distro[distro_id]
  end
end
