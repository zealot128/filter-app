Baseapp::Application.configure do
  config.cache_classes = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.eager_load = true
  config.serve_static_files = false
  config.assets.compress = true
  config.assets.compile = false
  config.assets.digest = true
  config.log_level = :info
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.action_mailer.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = YAML.load_file('config/email.yml')
  config.action_mailer.default_url_options = { host: Configuration.host }
  config.action_mailer.asset_host = "http://#{config.action_mailer.default_url_options[:host]}"
  # config.assets.js_compressor = :uglifier
  config.lograge.enabled = true
end
