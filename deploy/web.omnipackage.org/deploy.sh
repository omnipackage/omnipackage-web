#!/usr/bin/env bash

HOST="web.omnipackage.org"
USER="rocky"
DIR="/home/$USER/omnipackage-web"

if [ "$1" == "console" ]; then
  ssh -t $USER@$HOST "bash -lic 'cd $DIR && bin/rails c -e production'"
  exit 0
fi

ssh -T $USER@$HOST <<EOL
  set -xEeuo pipefail
	cd $DIR
  git pull
  export RAILS_ENV=production
  rbenv install --skip-existing
  bundle config --local without development test
  bundle config set deployment true
  bundle config build.pg --with-pg-include=/usr/pgsql-16/include/ --with-pg-lib=/usr/pgsql-16/lib/
  bundle install
  bin/rails assets:clean
  bin/rails assets:precompile
  bin/rails db:migrate
  sudo systemctl daemon-reload
  sudo systemctl restart sidekiq@default
  sudo systemctl restart sidekiq@long
  sudo systemctl restart puma
EOL
