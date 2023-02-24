# frozen_string_literal: true

class Project
  class Sources
    class Localfs < ::Project::Sources
      def probe
        ::File.exist?(location)
      end

      def clone
        if block_given?
          yield(location)
        else
          true
        end
      end
    end
  end
end
