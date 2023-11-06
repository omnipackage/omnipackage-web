# frozen_string_literal: true

class Repository
  class Manage
    def download(artefacts)
      artefacts.group_by(&:distro).each do |distro, afacts|
        create_repo_files(::Distro[distro], afacts)
      end
    end

    def sign
    end

    def upload
    end

    private

    def create_repo_files(distro, artefacts)
      case distro.package_type
      when 'rpm'
        ::Dir.mktmpdir do |dir|
          sap dir
          artefacts.select { |i| i.filetype == 'rpm' }.each { |i| i.download(to: dir) }
          rt = ::RepoManage::Runtime.new(executable: 'podman', workdir: dir, image: distro.image)
          ::RepoManage::Repo.new(runtime: rt, directory: dir, type: distro.package_type).refresh
          puts "*****"
          puts ::ShellUtil.execute("tree #{dir}").out
          puts ::ShellUtil.execute("ls -latrh #{dir}").out
          puts "*****"
        end
      end
    end


  end
end
