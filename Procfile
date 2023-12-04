web: bundle exec rails server -p 5000
sidekiq_default: bundle exec sidekiq -C config/sidekiq/default.yml
sidekiq_long: bundle exec sidekiq -C config/sidekiq/long.yml

#mailhog: ~/.go/bin/MailHog #&>/dev/null

minio: MINIO_ROOT_USER=`bundle exec rails runner 'puts ::Rails.application.credentials.s3.access_key_id'` MINIO_ROOT_PASSWORD=`bundle exec rails runner 'puts ::Rails.application.credentials.s3.secret_access_key'` ~/.go/bin/minio server ./storage/minio --console-address ":9001"
