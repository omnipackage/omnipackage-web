# frozen_string_literal: true

class Project
  class Sources
    attr_reader :kind, :location, :ssh_private_key

    def initialize(kind:, location:, ssh_private_key:)
      @kind = kind
      @location = location
      @ssh_private_key = ssh_private_key
    end

    def probe
      case kind
      when 'git'
        ::Git.new(ssh_private_key: ssh_private_key).ping(location)
      else
        raise "unsupported sources kind '#{kind}'"
      end
    end
  end
end
