Rails.application.configure do
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
  if ENV["FILTER_SMTP_ADDRESS"]
    ActionMailer::Base.smtp_settings = {
      address: ENV['FILTER_SMTP_ADDRESS'],
      authentication: ENV['FILTER_SMTP_AUTHENTICATION'],
      domain: ENV['FILTER_SMTP_DOMAIN'],
      enable_starttls_auto: ENV['FILTER_SMTP_ENABLE_STARTTLS_AUTO'] == 'true',
      password: ENV['FILTER_SMTP_PASSWORD'],
      port: ENV['FILTER_SMTP_PORT'].to_i,
      user_name: ENV['FILTER_SMTP_USER_NAME'],
    }
  else
    ActionMailer::Base.smtp_settings = YAML.load_file('config/email.yml')
  end
  config.action_mailer.default_url_options = { host: h = Rails.application.secrets.domain_name }
  config.action_mailer.asset_host = "http://#{h}"
  # config.assets.js_compressor = :uglifier
  config.lograge.enabled = true
end
