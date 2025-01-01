class Project
  class Sources
    class Localfs < ::Project::Sources
      def probe
        ::File.exist?(full_location)
      end

      def clone
        if block_given?
          yield(full_location)
        else
          true
        end
      end

      private

      def full_location
        ::Pathname.new(location).join(subdir).to_s
      end
    end
  end
end
