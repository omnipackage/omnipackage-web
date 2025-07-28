class Distro
  class << self
    include ::Enumerable

    delegate :each, to: :all

    def all
      @all ||= load_from_file.fetch('distros').map do |h| # rubocop: disable ThreadSafety/ClassInstanceVariable
        new(h)
      end
    end

    def all_active
      @all_active ||= all.reject(&:deprecated?) # rubocop: disable ThreadSafety/ClassInstanceVariable
    end

    def by_id(id)
      id = id.to_s.gsub('%2E', '.')
      find { |i| i.id == id } || (raise "no such distro '#{id}'")
    end
    alias [] by_id

    def by_ids(ids)
      select { |i| ids.include?(i.id) }
    end

    def by_arch(arch)
      select { |d| d.arch == arch }
    end

    def ids
      map(&:id)
    end

    def active_ids
      all_active.map(&:id)
    end

    def arches
      map(&:arch).uniq
    end

    def by_package_type(package_type)
      select { |d| d.package_type == package_type }
    end

    def load_from_file
      ::YAML.load_file(::Rails.root.join('config/distros.yml'), aliases: true)
    end
  end

  def initialize(config)
    @config = config.freeze
    freeze
  end

  %w[id name image package_type setup setup_repo install_steps arch image_info_url deprecated].each do |attr|
    define_method(attr) { config.fetch(attr) }
  end

  def rpm?
    package_type == 'rpm'
  end

  def deb?
    package_type == 'deb'
  end

  def family
    %w(opensuse ubuntu fedora debian mageia rocky alma redhat).find { |i| id.include?(i) } || 'unknown'
  end

  def slug
    id.gsub(/[^0-9a-z]/i, '-')
  end

  def deprecated?
    config['deprecated'].present?
  end

  def url_safe_id
    id.gsub('.', '%2E')
  end

  private

  attr_reader :config
end
