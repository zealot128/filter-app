# rubocop:disable Naming/MethodName
ignore_default_exceptions = [
  'ActiveRecord::RecordNotFound',
  'ActionController::RoutingError',
  'ActionController::InvalidAuthenticityToken',
  'CGI::Session::CookieStore::TamperedWithCookie',
  'ActionController::UnknownAction',
  'AbstractController::ActionNotFound',
  'Mongoid::Errors::DocumentNotFound'
].freeze
if Rails.application.secrets.airbrake_url.present?
  require 'airbrake'
  Airbrake.configure do |config|
    config.host = Rails.application.secrets.airbrake_url
    config.project_id = 1 # required, but any positive integer works
    config.project_key = Rails.application.secrets.airbrake_project_key
    config.environment = Rails.env
    config.ignore_environments = %w(development test)
  end
  Airbrake.add_filter do |notice|
    if notice[:errors].any? { |error| ignore_default_exceptions.include?(error[:type]) }
      notice.ignore!
    end
  end
  def NOTIFY_EXCEPTION(*args)
    Airbrake.notify(*args)
  end

elsif ENV['SENTRY_DSN']
  require 'sentry-raven'
  Raven.configure do |config|
    # config.dsn = ENV['SENTRY_DSN']
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  end
  def NOTIFY_EXCEPTION(*args)
    Raven.capture_exception(*args)
  end

elsif Rails.env.production?
  def NOTIFY_EXCEPTION(*args)
  end

else
  def NOTIFY_EXCEPTION(*args)
  end
end

def CATCH_ALL(&block)
  yield
rescue StandardError => e
  NOTIFY_EXCEPTION(e)
  raise e
end
