#source "http://bundler-api.herokuapp.com"
source 'https://rubygems.org'

gem 'rails', '~> 4.2.0'
gem "pg"
gem "simple_form"

gem "browser"
gem "bcrypt-ruby"
gem "sitemap_generator"
gem "httparty"
gem "feedjira"
gem 'mechanize'

group :capistrano do
  gem 'capistrano', '~> 3.0.1'
  gem 'capistrano-rvm', github: 'capistrano/rvm'
  gem 'capistrano-bundler'
  gem 'capistrano-rails', '~> 1.1.0'
  gem 'capistrano-rails-console'
  gem "whenever"
end
gem 'exception_notification'
gem "cache_digests"
gem "paperclip"

gem 'sass-rails'
gem 'coffee-rails'
gem 'bootstrap-sass', '~> 3.1'
gem "font-awesome-rails", '~> 4.0'
# gem 'therubyracer', :platforms => :ruby

gem 'uglifier', '>= 1.0.3'
gem 'jquery-rails'
gem "sass"
gem "haml-rails"
gem 'slim-rails'

group :test do
  gem 'timecop'
  gem "rspec-rails", '~> 2.14.0'
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

gem 'twitter', '~> 5.0.0.rc.1'
gem 'ruby-stemmer'
gem 'rinku', require: 'rails_rinku'
gem "devise"
