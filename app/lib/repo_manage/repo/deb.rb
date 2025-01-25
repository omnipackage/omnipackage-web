module RepoManage
  class Repo
    class Deb < ::RepoManage::Repo
      def refresh # rubocop: disable Metrics/MethodLength
        write_releases_script
=begin
        commands = import_gpg_keys_commands + [
          'dpkg-scanpackages . > Packages',
          "sed -e 's|Filename: .\/|Filename: |g' -i Packages", # HACK: remove ./ from filenames, otherwise apt install doesn't work with minio https://github.com/minio/minio/issues/18421

          'mv ./generate_releases_script.sh /tmp/',
          'chmod +x /tmp/generate_releases_script.sh',

          '/tmp/generate_releases_script.sh > Release',
          "gpg --armor --detach-sign -o Release.gpg Release",
          "gpg --armor --detach-sign --clearsign -o InRelease Release",
          'mv public.key Release.key',
        ]
=end

        commands = import_gpg_keys_commands + [
          'chmod +x /root/generate_releases_script.sh',

          'mkdir -p stable',
          'mv *.deb stable/',
          'dpkg-scanpackages stable/ > stable/Packages',
          'cat stable/Packages | gzip -9 > stable/Packages.gz',

          'cd stable/',
          '/root/generate_releases_script.sh > Release',
          'gpg --no-tty --batch --yes --armor --detach-sign -o Release.gpg Release',
          'gpg --no-tty --batch --yes --armor --detach-sign --clearsign -o InRelease Release',
          'mv ../public.key Release.key',
        ]

        runtime.execute(commands).success!
      end

      # curl -fsSL http://localhost:9000/1-ubuntu-22-04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/omnipackage-1-ubuntu-22-04.gpg > /dev/null

      private

      def write_releases_script # rubocop: disable Metrics/MethodLength
        # credit: https://earthly.dev/blog/creating-and-hosting-your-own-deb-packages-and-apt-repo/
        script = <<~SCRIPT
#!/bin/sh
set -e

do_hash() {
    HASH_NAME=$1
    HASH_CMD=$2
    echo "${HASH_NAME}:"
    for f in $(find -type f); do
        f=$(echo $f | cut -c3-) # remove ./ prefix
        if [ "$f" = "Release" ]; then
            continue
        fi
        echo " $(${HASH_CMD} ${f}  | cut -d" " -f1) $(wc -c $f)"
    done
}

cat << EOF
Origin: Omnipackage repository
Label: Example
Suite: stable
Codename: stable
Version: 1.0
Architectures: amd64
Components: main
Description: Omnipackage repository
Date: $(date -Ru)
EOF
do_hash "MD5Sum" "md5sum"
do_hash "SHA1" "sha1sum"
do_hash "SHA256" "sha256sum"
SCRIPT

        write_file(::Pathname.new(homedir).join('generate_releases_script.sh'), script)
      end
    end
  end
end
