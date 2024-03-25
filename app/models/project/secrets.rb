# frozen_string_literal: true

class Project
  class Secrets
    class << self
      def load(payload) = new(::JSON.load(payload))
      def dump(object) = ::JSON.dump(object.to_h)

      def from_env(str)
        new(str.lines.map { |line| line.chomp.split('=') }.to_h)
      end
    end

    include ::Enumerable

    delegate :each, to: :h

    def initialize(hash = {})
      @h = hash.to_h { |k, v| [k.to_s, v.to_s] }
    end

    def to_h = h

    def to_env
      map { |k, v| "#{k}=#{v}"}.join("\n")
    end

    private

    attr_reader :h
  end
end
