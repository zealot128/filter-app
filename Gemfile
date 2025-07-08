source "https://rubygems.org"

gem "rails", "~> 7.2.0"

gem "solid_cache", "~> 1.0"
gem "solid_queue", "~> 1.0"
gem "mission_control-jobs"
gem 'sqlite3'

gem 'babel-transpiler'
gem "pg"
gem "mail_form"
gem "simple_form"
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
gem 'parallel'

gem "ahoy_matey", "~> 2.1"
gem "rollups"
gem 'devise'
gem 'cancancan'
# gem 'devise-i18n'

gem "sentry-ruby"
gem "sentry-rails"

gem 'kt-paperclip'
gem "kt-paperclip-optimizer"

gem 'image_processing'
gem 'mini_magick'
gem 'datagrid'

gem 'rack', '~> 2.0'

gem 'google-cloud-firestore', require: false
gem 'google-cloud-firestore-v1', ">= 0.10", require: false
gem 'fcm', require: false
gem 'mjml-rails'
# gem 'mrml'

gem "vite_ruby", '~> 3.3.2'
gem "vite_rails", ">= 3.0.13"

gem 'rack-cors', require: 'rack/cors'

# TODO: > 5.0.7
gem "sass-rails", git: 'https://github.com/rails/sass-rails.git'
gem "font-awesome-rails", "~> 4.0"
gem "sass"
gem "slim-rails"
gem "migration_data"

gem 'grape'
gem 'active_model_serializers', '~> 0.10'

gem "ruby-stemmer"
gem "premailer-rails"
# TODO: https://github.com/johnkoht/zurb-ink/pull/1
gem "zurb-ink", git: 'https://github.com/pludoni/zurb-ink.git'
gem "rinku", require: "rails_rinku"
gem "ipcat"
gem "voight_kampff", require: "voight_kampff/rails"
gem 'semantic_range'

gem 'thruster', require: false

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
  gem 'ruby-lsp', require: false
  gem 'kamal', require: false
end

group :development, :test do
  gem 'puma'
  gem 'pludoni-rubocop', git: 'https://github.com/pludoni/pludoni-rubocop.git', require: false, ref: 'main'
end
# TODO: https://github.com/pry/pry/issues/2328
gem 'pry'
gem "pry-rails"
gem 'rack-attack'

group :capistrano do
  gem "whenever"
end

gem "meta-tags", "~> 2.13"
gem 'hashie'
