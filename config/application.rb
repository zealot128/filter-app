require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Baseapp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    ###
    config.i18n.default_locale = :de
    config.i18n.locale = :de
    config.encoding = "utf-8"
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    config.middleware.use Rack::Attack
    config.active_record.belongs_to_required_by_default = false
    config.active_job.queue_adapter = :sidekiq

    config.generators do |g|
      g.template_engine :haml
      g.test_framework = :rspec
      g.helper false
      g.view_specs false
      # g.form_builder :simple_form
    end
  end
end
