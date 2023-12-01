# frozen_string_literal: true

class Agent < ::ApplicationRecord
  encrypts :apikey, deterministic: true

  has_many :tasks, class_name: '::Task', dependent: :nullify
  belongs_to :user, class_name: '::User', optional: true

  validates :apikey, presence: true, uniqueness: true
  validates :name, presence: true, length: { maximum: 200 }
  validates :arch, presence: true, inclusion: { in: ::Distro.arches }

  broadcast_with ::Broadcasts::Agent

  after_update_commit do
    ::AgentStatusCheckJob.set(wait_until: considered_offline_at + rand(1..5).seconds).perform_later(id)
  end

  scope :offline, -> { where('? > considered_offline_at', ::Time.now.utc) }
  scope :online, -> { where('? <= considered_offline_at', ::Time.now.utc) }
  scope :public_shared, -> { where(user_id: nil) }
  scope :busy, -> { joins(:tasks).where(tasks: { state: 'running' }) }

  def touch_last_seen(next_poll_after)
    tm = ::Time.now.utc
    update(last_seen_at: tm, considered_offline_at: tm + next_poll_after + 5)
  end

  def offline?
    return true unless considered_offline_at

    ::Time.now.utc > considered_offline_at
  end

  def online?
    !offline?
  end

  def busy?
    online? && tasks.running.exists?
  end

  def idle?
    online? && !tasks.running.exists?
  end

  def next_poll_after
    rand(19..29)
  end

  def supported_distros
    ::Distro.by_arch(arch)
  end
end
