# frozen_string_literal: true

module RepoManage
  class Repo
    class Deb < ::RepoManage::Repo
      def refresh
        runtime.execute('dpkg-scanpackages . /dev/null > Release').success!
      end
    end
  end
end
