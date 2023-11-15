# frozen_string_literal: true

module RepoManage
  class Repo
    class Rpm < ::RepoManage::Repo
      def refresh
        write_rpmmacros

        commands = import_gpg_keys_commands + [
          'rpm --import public.key',
          'rpm --addsign *.rpm',
          'createrepo .',
          'gpg --no-tty --batch --detach-sign --armor --verbose --yes --always-trust repodata/repomd.xml',
          'mv public.key repodata/repomd.xml.key'
        ]
        runtime.execute(commands).success!

        write_repo_file
      end

      private

      def write_repo_file
        repo = <<~FILE
        [#{project_safe_name}]
        name=#{project_safe_name} (#{distro_name})
        type=rpm-md
        baseurl=#{distro_url}
        gpgcheck=1
        gpgkey=#{distro_url}/repodata/repomd.xml.key
        enabled=1
        FILE
        write_file(::Pathname.new(workdir).join("#{project_safe_name}.repo"), repo)
      end

      def write_rpmmacros
        rpmmacros = <<~FILE
        %_signature gpg
        %_gpg_name #{gpg_key_id}
        FILE
        write_file(::Pathname.new(homedir).join('.rpmmacros'), rpmmacros)
      end
    end
  end
end
