ENV["RAILS_ENV"] ||= 'test'
if ENV['CI']
  require 'simplecov'
  SimpleCov.start 'rails' do
    # add_filter do |source_file|
    #   source_file.lines.count < 10
    # end
    add_group "Long files" do |src_file|
      src_file.lines.count > 150
    end
  end
end
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

silence_warnings do
  require "bcrypt"
  BCrypt::Engine::DEFAULT_COST = BCrypt::Engine::MIN_COST
end

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
  config.infer_spec_type_from_file_location!
  config.tty = true

  config.before(:each) do
    ActionMailer::Base.deliveries = []
  end
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock # or :fakeweb
end
