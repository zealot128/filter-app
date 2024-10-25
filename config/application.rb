require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Baseapp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    ######
    config.i18n.default_locale = :de
    config.i18n.locale = :de
    config.encoding = "utf-8"
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    config.middleware.use Rack::Attack
    config.active_record.belongs_to_required_by_default = false
    config.active_job.queue_adapter = :sidekiq
    # Disable host whitelisting... braucht man nicht da wir das immer selbst machen
    config.hosts.clear
    config.active_storage.variant_processor = :mini_magick
    config.active_support.cache_format_version = 7.0
    config.secrets = config_for(:secrets)

    config.generators do |g|
      g.template_engine :haml
      g.test_framework = :rspec
      g.helper false
      g.view_specs false
      # g.form_builder :simple_form
    end
  end
end
