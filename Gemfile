source "https://rubygems.org"

gem "rails", "~> 7.0.0"

# # TODO: Ruby 2.7: Warnings
# # https://github.com/ruby/net-protocol/issues/10
# # https://stackoverflow.com/questions/70443856/ruby-2-7-4-net-constant-warnings
# # after upgrading to Ruby 3+ URI must be fixed in paperclip, grape etc.
# gem 'uri', '0.10.0.2' # force the default version for ruby 2.7
# gem 'net-http'
#
gem 'babel-transpiler'
gem "pg"
gem "mail_form"
gem "simple_form"
gem "simple-navigation"
gem "simple-navigation-bootstrap", git: "https://github.com/pzgz/simple-navigation-bootstrap.git"
gem 'bootsnap'
gem 'invisible_captcha'
gem "groupdate"
gem "browser"
gem "bcrypt-ruby"
gem "sitemap_generator"
gem "httparty"
gem "feedjira"
gem 'faraday_middleware'
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
gem "rollups"
gem 'devise'
gem 'cancancan'
# gem 'devise-i18n'

gem "sentry-raven", require: false

gem 'kt-paperclip'
gem "kt-paperclip-optimizer"

gem 'image_processing'
gem 'mini_magick'
gem 'datagrid'

gem 'rack', '~> 2.0'
gem 'sidekiq', '~> 6.5.10'
gem 'sidekiq-unique-jobs', '~> 7.1.33'
gem 'redis-namespace', '~> 1.5'

gem 'google-cloud-firestore', require: false
gem 'google-cloud-firestore-v1', ">= 0.10", require: false
gem 'fcm', require: false
gem 'mjml-rails'

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

gem "twitter", "~> 7.0.0"
gem "omniauth-twitter"
gem "ruby-stemmer"
gem "premailer-rails"
# TODO: https://github.com/johnkoht/zurb-ink/pull/1
gem "zurb-ink", git: 'https://github.com/pludoni/zurb-ink.git'
gem "rinku", require: "rails_rinku"
gem "ipcat"
gem "voight_kampff", require: "voight_kampff/rails"
gem "owlcarousel-rails", git: 'https://github.com/pludoni/owlcarousel-rails.git'
gem 'semantic_range'

group :test do
  gem "fuubar"
  gem 'rails-controller-testing'
  gem "timecop"
  gem 'pludoni_rspec'
  gem "rspec-rails"
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
  gem 'puma'
  gem 'pludoni-rubocop', git: 'https://github.com/pludoni/pludoni-rubocop.git', require: false, ref: 'main'
end
gem "pry-rails"
gem 'rack-attack'

group :capistrano do
  gem "whenever"
end

gem "meta-tags", "~> 2.13"
