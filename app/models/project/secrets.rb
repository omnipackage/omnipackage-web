class Project
  class Secrets
    class << self
      def load(payload) = new(::JSON.parse(payload.presence || '{}'))

      def dump(object)
        return if object.blank?

        object = from_env(object) if object.is_a?(::String)
        ::JSON.dump(object.to_h)
      end

      def from_env(str)
        hash = str.lines.map do |line|
          k, v = line.chomp.split('=', 2)
          [k, v]
        end.to_h
        new(hash)
      end
    end

    include ::Enumerable

    delegate :each, :empty?, to: :h

    def initialize(hash = {})
      @h = hash.to_h { |k, v| [k.to_s, v.to_s] }
    end

    def to_h = h

    def to_env
      map { |k, v| "#{k}=#{v}" }.join("\n")
    end

    def valid?
      all? { |k, v| k.present? && v.present? }
    end

    private

    attr_reader :h
  end
end
