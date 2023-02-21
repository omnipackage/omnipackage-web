# frozen_string_literal: true

class Project
  class Sources
    attr_reader :kind, :location

    def initialize(kind:, location:)
      @kind = kind
      @location = location
    end

    def probe
      case kind
      when 'git'
        ::Git.new.ping(location)
      else
        raise "unsupported sources kind '#{kind}'"
      end
    end
  end
end
