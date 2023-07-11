# frozen_string_literal: true

class Repository
  class Manage
    def download_artefact(artefact)
      ::Dir.mktmpdir do |dir|
        sap "tmp dir: #{dir}"
        artefact.download(to: dir)
        # create repo files
        # sign
        # upload
      end
    end

    def sign
    end

    def upload
    end
  end
end
