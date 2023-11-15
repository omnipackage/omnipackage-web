# frozen_string_literal: true

class Distro
  class << self
    include ::Enumerable

    delegate :each, to: :all

    def all
      @all ||= load_from_file.fetch('distros').map do |h|
        new(h)
      end
    end

    def by_id(id)
      find { |i| i.id == id.to_s } || (raise "no such distro '#{id}'")
    end
    alias [] by_id

    def by_ids(ids)
      select { |i| ids.include?(i.id) }
    end

    def ids
      map(&:id)
    end

    def arches
      map(&:arch).uniq
    end

    def load_from_file
      ::YAML.load_file(::Rails.root.join('config/distros.yml'), aliases: true)
    end
  end

  def initialize(config)
    @config = config.freeze
    freeze
  end

  %w[id name image package_type setup setup_repo install_steps arch].each do |attr|
    define_method(attr) { config.fetch(attr) }
  end

  def rpm?
    package_type == 'rpm'
  end

  def deb?
    package_type == 'deb'
  end

  private

  attr_reader :config
end
