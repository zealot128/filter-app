require 'redis/namespace'

redis_config = if ENV['REDIS_URL']
                 {
                   url: ENV['REDIS_URL'],
                   namespace: "filter_#{Rails.env}"
                 }
               elsif ENV['REDIS_PORT_6379_TCP_PORT']
                 {
                   url: "redis://#{ENV['REDIS_PORT_6379_TCP_ADDR']}:#{ENV['REDIS_PORT_6379_TCP_PORT']}/0",
                   namespace: "filter_#{Rails.env}"
                 }
               else
                 {
                   url: 'redis://localhost:6379/1',
                   namespace: "filter_#{Rails.env}"
                 }
               end

Redis::Namespace::COMMANDS['lock'] = [:all]
Redis::Namespace::COMMANDS['unlock'] = [:all]

require "sidekiq-unique-jobs"
Sidekiq.configure_client do |config|
  config.redis = redis_config
  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end
  # ActiveRecord::Base.establish_connection
end
Sidekiq.configure_server do |config|
  config.redis = redis_config
  config.server_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Server
  end

  SidekiqUniqueJobs::Server.configure(config)
end
if Rails.env.production?
  Sidekiq.logger = Rails.logger
end
Sidekiq.default_job_options = { retry: 1 }

require 'sidekiq/web'
