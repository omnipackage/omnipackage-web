# frozen_string_literal: true

module RepoManage
  class Repo
    class Rpm < ::RepoManage::Repo
      def refresh
        write_rpmmacros

        commands = import_gpg_keys_commands + [
          'rpm --import /root/key.pub',
          'rpm --showrc --verbose --addsign *.rpm',
          'createrepo .',
          'gpg --detach-sign --armor --verbose --yes --always-trust repodata/repomd.xml'
        ]
        runtime.execute(commands).success!
      end

      private

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
