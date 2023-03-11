# frozen_string_literal: true

class Agent < ::ApplicationRecord
  encrypts :apikey, deterministic: true

  has_many :agent_tasks, class_name: '::Agent::Task', dependent: :destroy
  belongs_to :user, class_name: '::User', optional: true

  validates :apikey, presence: true, uniqueness: true

  scope :offline, -> { where('? > considered_offline_at', ::Time.now.utc) }
  scope :online, -> { offline.invert_where }

  def touch_last_seen(next_poll_after)
    tm = ::Time.now.utc
    update(last_seen_at: tm, considered_offline_at: tm + next_poll_after + 5)
  end

  def offline?
    ::Time.now.utc > considered_offline_at
  end

  def online?
    !offline?
  end
end
