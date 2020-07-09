source "https://rubygems.org"

gem "rails", "~> 6.0.0"
gem 'babel-transpiler'
gem "pg"
gem "mail_form"
gem "simple_form"
gem "simple-navigation"
gem "simple-navigation-bootstrap", git: "https://github.com/pzgz/simple-navigation-bootstrap.git"
gem 'bootsnap'

gem "groupdate"
gem "browser"
gem "bcrypt-ruby"
gem "sitemap_generator"
gem "httparty"
gem "feedjira"
gem "excon"
gem 'typhoeus'
gem "mechanize"
gem "pg_search"
gem "will_paginate-bootstrap"
gem "stringex"
gem "auto_strip_attributes", "~> 2.5"
gem "email_verifier", git: "https://github.com/pludoni/email_verifier.git"
gem "lograge"
gem "open_uri_redirections"
gem "angularjs-rails", "1.2.18"
gem 'parallel'

gem "ahoy_matey", "~> 2.1"
gem 'devise'
gem 'cancancan'
# gem 'devise-i18n'

gem "sentry-raven", require: false

gem "paperclip"
gem "paperclip-optimizer"
gem 'image_optim_pack'
gem 'mini_magick'
gem 'datagrid'

gem 'rack', '~> 2.0'
gem 'sidekiq'
gem 'sidekiq-unique-jobs'
gem 'redis-namespace', '~> 1.5.0'

gem 'google-cloud-firestore', require: false
gem 'fcm', require: false

gem 'webpacker', '~> 5.x'

gem 'rack-cors', require: 'rack/cors'

# TODO: > 5.0.7
gem "sass-rails", git: 'https://github.com/rails/sass-rails.git'
gem "coffee-rails"
gem "bootstrap-sass", "~> 3.1"
gem "bootswatch-rails"
gem "font-awesome-rails", "~> 4.0"
# gem "therubyracer", :platforms => :ruby

gem "uglifier", ">= 1.0.3"
gem "jquery-rails"
gem "sass"
gem "slim-rails"
gem "highcharts-rails"
gem "migration_data"

gem 'grape'
gem 'active_model_serializers', '~> 0.10'

gem "twitter", "~> 6.2.0"
gem "omniauth-twitter"
gem "ruby-stemmer"
gem "premailer-rails"
# TODO: https://github.com/johnkoht/zurb-ink/pull/1
gem "zurb-ink", git: 'https://github.com/pludoni/zurb-ink.git'
gem "rinku", require: "rails_rinku"
gem "ipcat"
gem "voight_kampff"
gem "owlcarousel-rails", git: 'https://github.com/pludoni/owlcarousel-rails.git'

group :test do
  gem 'rails-controller-testing'
  gem "timecop"
  gem 'pludoni_rspec', git: 'https://github.com/pludoni/pludoni_rspec.git'
  gem "rspec-rails", ">= 4.0.0.beta2"
  gem "vcr"
  gem "webmock"
  gem "fabrication"
  gem "apparition"
end

group :development do
  gem 'annotate'
  gem "habtm_generator"
  gem "listen"
  gem "foreman"
end

group :development, :test do
  gem "thin"
end
gem "pry-rails"
gem 'rack-attack'

group :capistrano do
  gem "whenever"
  gem "rubocop"
end

gem "meta-tags", "~> 2.13"
