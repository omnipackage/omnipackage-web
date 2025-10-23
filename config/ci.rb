::CI.run do
  step 'Setup', 'bin/setup'
  step 'Lint', 'bundle exec rubocop -DP'

  step 'Brakeman', 'bundle exec brakeman --no-pager'
  step 'Bundle audit', 'bundle exec bundler-audit check --update'

  step 'Unit tests', 'bundle exec rails test'

  step 'System tests', 'bundle exec rails test:system'
end
