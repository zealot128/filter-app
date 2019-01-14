require 'redis/namespace'
require 'airbrake/sidekiq'

redis_config = if ENV['REDIS_PORT_6379_TCP_PORT']
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
Sidekiq.configure_client do |config|
  config.redis = redis_config
  # ActiveRecord::Base.establish_connection
end
Sidekiq.configure_server do |config|
  config.redis = redis_config
end
if Rails.env.production?
  Sidekiq::Logging.logger = Rails.logger
end
Sidekiq.default_worker_options = { retry: 1 }

require 'sidekiq/web'
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]
if Rails.env.production?
  Sidekiq::Web.use(Rack::Auth::Basic) do |username, password|
    # Protect against timing attacks:
    # - See https://codahale.com/a-lesson-in-timing-attacks/
    # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
    # - Use & (do not use &&) so that it doesn't short circuit.
    # - Use digests to stop length information leaking (see also ActiveSupport::SecurityUtils.variable_size_secure_compare)
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(Rails.application.secrets.http_username)) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(Rails.application.secrets.http_password))
  end
end
