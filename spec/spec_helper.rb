ENV["RAILS_ENV"] ||= 'test'

require 'pludoni_rspec'
PludoniRspec.run

RSpec.configure do |config|
  config.before(:all) do
    Setting.read_yaml
  end
end
