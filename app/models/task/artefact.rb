# frozen_string_literal: true

class Task
  class Artefact < ::ApplicationRecord
    belongs_to :task, class_name: '::Task'

    has_one_attached :attachment

    attribute :distro, :string

    validates :distro, presence: true, inclusion: { in: ::Distro.ids }
    validates :attachment, presence: true
  end
end
