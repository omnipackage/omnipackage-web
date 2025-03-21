#!/usr/bin/env bash

HOST="51.210.222.18"
USER="debian"
DIR="/home/$USER/omnipackage-web"
BRANCH=`git branch --show-current`

SKIP_CADDY=0
SKIP_SIDEKIQ=0

POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
  case $1 in
    -c|--console)
      ssh -t $USER@$HOST "bash -lic 'cd $DIR && bin/rails c -e production'"
      exit $?
      ;;
    -s|--shell)
      ssh -t $USER@$HOST "cd $DIR && RAILS_ENV=production bash -li"
      exit $?
      shift
      ;;
    --skip-caddy)
      SKIP_CADDY=1
      shift
      ;;
    --skip-sidekiq)
      SKIP_SIDEKIQ=1
      shift
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done
set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

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

  bin/bundle install
  # bin/rails assets:clean
  bin/rails assets:precompile
  bin/rails db:migrate

  sudo systemctl daemon-reload
  if (( $SKIP_SIDEKIQ == 0 )); then
    sudo systemctl restart sidekiq@default
    sudo systemctl restart sidekiq@long
    sudo systemctl restart sidekiq@publish
  fi
  if (( $SKIP_CADDY == 0 )); then
    sudo systemctl restart caddy
  fi
  sudo systemctl restart puma
EOL
