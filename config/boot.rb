require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])

## Fix: always bind to host 0.0.0.0
require 'rails/commands/server'
module Rails
  class Server
    def default_options
      super.merge(Host: '0.0.0.0', Port: 3000)
    end
  end
end
