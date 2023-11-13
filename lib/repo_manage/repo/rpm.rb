# frozen_string_literal: true

module RepoManage
  class Repo
    class Rpm < ::RepoManage::Repo
      def refresh
        setup_rpmmacros

        commands = [
          'rpm --import /root/key.pub > /root/importpub',
          'rpm --showrc --verbose --addsign *.rpm > /root/rpmsign',
          'createrepo .',
          'gpg --detach-sign --armor repodata/repomd.xml'
        ]
        runtime.execute(commands).success!
      end

      private

      def setup_rpmmacros
=begin

      rpmmacros = <<~FILE
      %_signature gpg
      %_gpg_name #{keyid}
      %_gpg_pass -
      %__gpg_sign_cmd %{__gpg} gpg --force-v3-sigs --batch --no-verbose --no-armor --passphrase-file /root/passphrase --no-secmem-warning -u %{_gpg_name} -sbo %{__signature_filename} --digest-algo sha256 %{__plaintext_filename}'
      FILE
=end
        #       %__gpg_sign_cmd %{__gpg} gpg --batch --verbose --no-armor --no-secmem-warning -u "%{_gpg_name}" -sbo %{__signature_filename} --digest-algo sha256 %{__plaintext_filename}'

        # write_file(::Pathname.new(homedir).join('passphrase'), "\n")
        rpmmacros = <<~FILE
        %_signature gpg
        %_gpg_name #{gpg_key_id}
        FILE
        write_file(::Pathname.new(homedir).join('.rpmmacros'), rpmmacros)
      end
    end
  end
end
