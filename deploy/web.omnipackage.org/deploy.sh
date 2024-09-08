#!/usr/bin/env bash

HOST="51.75.147.84"
USER="debian"
DIR="/home/$USER/omnipackage-web"
BRANCH=`git branch --show-current`

if [ "$1" == "console" ] || [ "$1" == "c" ]; then
  ssh -t $USER@$HOST "bash -lic 'cd $DIR && bin/rails c -e production'"
  exit $?
fi

if [ "$1" == "shell" ] || [ "$1" == "s" ]; then
  ssh -t $USER@$HOST "cd $DIR && RAILS_ENV=production bash -li"
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

  function notify_rollbar() {
    local token=`bundle exec rails runner 'puts ::Rails.application.credentials.rollbar_api_key'`
    local revision=`git rev-parse --short HEAD`
    local rollbar_name=`git log -1 --pretty=format:'%an'`
    local local_username=`whoami`
    local comment=`git log -1 --pretty=%B`

    local payload=`cat <<EOF
{
  "environment": "$RAILS_ENV",
  "revision": "$revision",
  "rollbar_name": "$rollbar_name",
  "local_username": "$local_username",
  "comment": "$comment",
  "status": "succeeded"
}
EOF`
    curl -H "X-Rollbar-Access-Token: $token" -H "Content-Type: application/json" -X POST 'https://api.rollbar.com/api/1/deploy' -d "$payload"
  }
  notify_rollbar
EOL
