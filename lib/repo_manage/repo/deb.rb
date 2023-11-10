# frozen_string_literal: true

module RepoManage
  class Repo
    class Deb < ::RepoManage::Repo
      def refresh
        runtime.execute('dpkg-scanpackages . /dev/null > Packages').success!

        ::File.open(::Pathname.new(workdir).join('generate_releases_script.sh'), 'w') do |file|
          file.write(generate_releases_script)
        end

        runtime.execute('mv ./generate_releases_script.sh /tmp/ && chmod +x /tmp/generate_releases_script.sh').success!
        runtime.execute('/tmp/generate_releases_script.sh > Release').success!
      end

      private

      def generate_releases_script
        # credit: https://earthly.dev/blog/creating-and-hosting-your-own-deb-packages-and-apt-repo/
        <<~SCRIPT
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
      end
    end
  end
end
