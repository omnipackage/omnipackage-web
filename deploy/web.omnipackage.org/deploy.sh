#!/usr/bin/env bash

HOST="web.omnipackage.org"
USER="rocky"
DIR="/home/$USER/omnipackage-web"

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
EOL
