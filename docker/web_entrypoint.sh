#!/bin/sh
set -e

bin/rails db:prepare

bin/rails runner 'eval(STDIN.read)' <<'RUBY'
unless Agent.exists?
  2.times do
    agent = Agent.create!(name: "embedded_#{_1 + 1}", arch: ::Distro.arches.first)
    puts "Created embedded agent: #{agent.name}"
  end
end

unless User.exists?
  email = 'admin@omnipackage.local'
  password = '12345678'
  user = User.create!(email:, password: , root: true, slug: 'admin')
  puts "Created user: #{email} with password #{password}"
end
RUBY

bin/rails server -b 0.0.0.0 -p 3000
