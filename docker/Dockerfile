FROM opensuse/tumbleweed

WORKDIR /app

RUN zypper dup -y && zypper in -y patterns-devel-base-devel_basis postgresql-devel libxml2-devel libyaml-devel podman ruby-devel git openssh tree

RUN zypper --non-interactive --gpg-auto-import-keys addrepo \
      https://repositories.omnipackage.org/oleg/omnipackage-agent/opensuse-tumbleweed/omnipackage-agent.repo \
 && zypper --non-interactive --gpg-auto-import-keys refresh \
 && zypper --non-interactive in omnipackage-agent


ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV WEB_CONCURRENCY=0

COPY . .

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails .
USER 1000:1000

RUN bundle config set --local without development test && \
    bundle config set --local deployment true && \
    bundle config set --local path vendor/bundle && \
    bundle config set --local simulate_version 4

RUN bundle install
RUN bundle exec bootsnap precompile --gemfile app/ lib/
RUN SECRET_KEY_BASE=123 bin/rails assets:precompile
