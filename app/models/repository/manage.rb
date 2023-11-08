# frozen_string_literal: true

class Repository
  class Manage
    def call(task)
      return unless task.finished?

      task.artefacts.group_by(&:distro).each do |distro, afacts|
        ::Dir.mktmpdir do |dir|
          task.project.repositories.find_by(distro_id: distro)&.download_all(to: dir)
          create_or_update_repo_files(::Distro[distro], afacts, dir)
        end
      end
    end

    private

    def create_or_update_repo_files(distro, artefacts, dir)
      case distro.package_type
      when 'rpm'
        artefacts.select { |i| i.filetype == 'rpm' }.each { |i| i.download(to: dir, overwrite_existing: true) }
        rt = ::RepoManage::Runtime.new(executable: 'podman', workdir: dir, image: distro.image, setup_cli: distro.setup_repo)
        ::RepoManage::Repo.new(runtime: rt, directory: dir, type: distro.package_type).refresh
        puts "*****" # rubocop: disable Rails/Output
        puts ::ShellUtil.execute("tree #{dir}").out # rubocop: disable Rails/Output
        puts "*****" # rubocop: disable Rails/Output
      end
    end
  end
end
