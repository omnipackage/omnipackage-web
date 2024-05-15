# frozen_string_literal: true

class PruneImagesJob < ::ApplicationJob
  queue_as :long

  def perform
    containers
    images
  end

  private

  def max_age
    '120h'
  end

  def excecutable
    ::APP_SETTINGS.fetch(:container_runtime)
  end

  def containers
    ::ShellUtil.execute("#{excecutable} container prune -f --filter 'until=#{max_age}'", timeout_sec: 4.hour.to_i).success!
  end

  def images
    ::ShellUtil.execute("#{excecutable} image prune -af --filter 'until=#{max_age}'", timeout_sec: 8.hours.to_i).success!
  end
end
