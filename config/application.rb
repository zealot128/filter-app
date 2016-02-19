require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(assets: %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Baseapp
  class Application < Rails::Application
    config.i18n.default_locale = :de
    config.i18n.locale = :de
    config.encoding = "utf-8"
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    config.assets.precompile += %w( font-awesome-ie7.min.css web.css web.js IE9.js admin.js app.js mailer.css)

    config.assets.enabled = true
    config.assets.version = '1.0'
    config.assets.image_optim = false
    config.active_record.raise_in_transactional_callbacks = true

    config.generators do |g|
      g.template_engine :haml
      g.test_framework = :rspec
      g.helper false
      g.view_specs false
      g.form_builder :simple_form
    end
  end
end
