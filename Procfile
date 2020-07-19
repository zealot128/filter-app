web: bundle exec rails server -p $PORT
sidekiq: bundle exec sidekiq -q low -q default -q mailers -q important --verbose -c 1
webpack: bin/webpack-dev-server
