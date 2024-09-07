#!/usr/bin/env bash

HOST="51.75.147.84"
USER="debian"
DIR="/home/$USER/omnipackage-web"
BRANCH=`git branch --show-current`

if [ "$1" == "console" ] || [ "$1" == "c" ]; then
  ssh -t $USER@$HOST "bash -lic 'cd $DIR && bin/rails c -e production'"
  exit $?
fi

ssh -T $USER@$HOST <<EOL
  set -xEeuo pipefail
  cd ~/.rbenv/ && git pull && cd ~/.rbenv/plugins/ruby-build/ && git pull
	cd $DIR
  git checkout $BRANCH
  git pull
  export RAILS_ENV=production
  rbenv install --skip-existing
  bundle config --local without development test
  bundle config set deployment true
  # bundle config build.pg --with-pg-include=/usr/pgsql-16/include/ --with-pg-lib=/usr/pgsql-16/lib/
  bundle install
  bin/rails assets:clean
  bin/rails assets:precompile
  bin/rails db:migrate
  sudo systemctl daemon-reload
  sudo systemctl restart sidekiq@default
  sudo systemctl restart sidekiq@long
  sudo systemctl restart sidekiq@publish
  sudo systemctl restart puma
  sudo systemctl restart caddy
EOL
