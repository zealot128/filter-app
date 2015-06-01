
# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

require 'capistrano/rvm'
require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
require 'capistrano/rails/console'
require 'capistrano/version'
require "airbrussh/capistrano"

Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }

