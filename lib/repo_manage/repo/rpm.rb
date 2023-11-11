# frozen_string_literal: true

module RepoManage
  class Repo
    class Rpm < ::RepoManage::Repo
      def refresh
        runtime.execute('createrepo .').success!
      end
    end
  end
end
