web: bundle exec rails server -p 5000
sidekiq: bundle exec sidekiq
mailhog: ~/.go/bin/MailHog &>/dev/null
minio: MINIO_ROOT_USER=admin MINIO_ROOT_PASSWORD=password ~/.go/bin/minio server ./storage/minio --console-address ":9001"
