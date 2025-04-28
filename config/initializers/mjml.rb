Mjml.setup do |config|
  config.use_mrml = true
  # Use :haml as a template language
  config.template_language = :slim

  # Ignore errors silently
  config.raise_render_exception = !Rails.env.production?
  # config.raise_render_exception = false
  config.use_mrml = false

  # Optimize the size of your emails
  # config.beautify = false
  # config.minify = true

  # Render MJML templates with errors
  config.validation_level = "soft"

  # Use custom MJML binary with custom version
  # config.mjml_binary = "/path/to/custom/mjml"
  # config.mjml_binary_version_supported = "3.3.5"
end
