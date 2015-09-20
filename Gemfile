#source "http://bundler-api.herokuapp.com"
source 'https://rubygems.org'

gem 'rails', '~> 4.2.0'
gem 'rack', '1.6.2'
gem 'sprockets-es6'
gem "pg"
gem "simple_form"

gem "browser"
gem "bcrypt-ruby"
gem "sitemap_generator"
gem "httparty"
gem "feedjira"
gem 'mechanize'
gem 'pg_search'
gem 'will_paginate-bootstrap'
gem 'stringex'
gem 'email_verifier', git: 'https://github.com/zealot128-os/email_verifier.git'
gem 'lograge'
gem 'open_uri_redirections'


source 'https://rails-assets.org' do
  gem 'rails-assets-director'
  gem 'rails-assets-shufflejs'
end

group :capistrano do
  gem 'capistrano'
  gem 'capistrano-rvm'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rails-console'
  gem "airbrussh", :require => false
  gem "whenever"
end
gem 'impressionist'
gem 'exception_notification'
gem "paperclip"
gem "paperclip-optimizer"

gem 'sass-rails'
gem 'coffee-rails'
gem 'bootstrap-sass', '~> 3.1'
gem 'bootswatch-rails'
gem "font-awesome-rails", '~> 4.0'
# gem 'therubyracer', :platforms => :ruby

gem 'uglifier', '>= 1.0.3'
gem 'jquery-rails'
gem "sass"
gem "haml-rails"
gem 'slim-rails'

group :test do
  gem 'timecop'
  gem "rspec-rails", '~> 2.14'
  gem "guard-rspec"
  gem "vcr"
  gem 'webmock'
end

group :development do
  gem 'fontsquirrel-download'
  gem "better_errors"
  gem "binding_of_caller"
  gem 'habtm_generator'
end

group :development, :test do
  gem "pry-rails"
  gem 'rb-inotify', '~> 0.9'
  gem "thin"
end

gem 'twitter', '~> 5.0'
gem 'ruby-stemmer'
gem 'roadie-rails'
gem 'rinku', require: 'rails_rinku'
