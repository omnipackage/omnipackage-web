# frozen_string_literal: true

class Distro
  class << self
    include ::Enumerable

    delegate :each, to: :all

    def all
      @all ||= ::YAML.load_file(::Rails.root.join('config/distros.yml'), aliases: true).fetch('distros').map do |h|
        new(**h.symbolize_keys)
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

    def all_to_hash
      each_with_object({}) { |elem, acc| acc[elem.id] = elem.to_hash }.freeze
    end
  end

  attr_reader :id, :name, :image, :package_type, :setup, :setup_repo, :install_steps

  def initialize(**kwargs)
    @id = kwargs.fetch(:id)
    @name = kwargs.fetch(:name)
    @package_type = kwargs.fetch(:package_type)
    @image = kwargs.fetch(:image)
    @setup = kwargs.fetch(:setup).freeze
    @setup_repo = kwargs.fetch(:setup_repo).freeze
    @install_steps = kwargs.fetch(:install_steps).freeze
    freeze
  end

  def rpm?
    package_type == 'rpm'
  end

  def deb?
    package_type == 'deb'
  end

  def to_hash
    {
      'id' => id,
      'name' => name,
      'package_type' => package_type,
      'image' => image,
      'setup' => setup,
      'setup_repo' => setup_repo
    }.freeze
  end
end
