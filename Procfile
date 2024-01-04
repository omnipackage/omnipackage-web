web: bundle exec rails server -p `bundle exec rails runner 'puts ::Rails.application.config.action_mailer.default_url_options.fetch(:port, 3000)'`

sidekiq_default: bundle exec sidekiq -C config/sidekiq/default.yml

sidekiq_long: bundle exec sidekiq -C config/sidekiq/long.yml

#
# go install github.com/mailhog/MailHog@latest
mailhog: ~/.go/bin/MailHog >/dev/null

#
# go install github.com/minio/minio@latest
minio: MINIO_ROOT_USER=`bundle exec rails runner 'puts ::Rails.application.credentials.s3.access_key_id'` MINIO_ROOT_PASSWORD=`bundle exec rails runner 'puts ::Rails.application.credentials.s3.secret_access_key'` ~/.go/bin/minio server ./storage/minio --console-address ":9001"

#agents: bundle exec rails embedded_agents:run > /dev/null

#
# mkdocs documentation in sibling folder
docs: test -f ../omnipackage-docs/Makefile && cd ../omnipackage-docs && make
