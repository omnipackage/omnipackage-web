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
  end

  attr_reader :id, :name, :image, :package_type, :setup

  def initialize(id:, name:, image:, package_type:, setup:)
    @id = id
    @name = name
    @package_type = package_type
    @image = image
    @setup = setup.freeze
    freeze
  end

  def rpm?
    package_type == 'rpm'
  end

  def deb?
    package_type == 'deb'
  end
end
