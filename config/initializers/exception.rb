# rubocop:disable Naming/MethodName
if ENV['SENTRY_DSN']
  SENTRY_RELEASE = if File.exist?("GIT_REVISION")
                     File.read("GIT_REVISION")
                   else
                     ""
                   end
  Sentry.init do |config|
    # config.dsn = ENV['SENTRY_DSN']
    config.enabled_environments = %w[production]
    config.release = SENTRY_RELEASE
    if ENV['SENTRY_DSN'].include?('sentry.pludoni')
      config.send_default_pii = true
    end
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    config.before_send = ->(event, _hint) do
      filter.filter(event.to_hash)
    end
    config.excluded_exceptions =
      Sentry::Configuration::IGNORE_DEFAULT  + [
        'ActiveRecord::RecordNotFound',
        'ActionController::RoutingError',
        'ActionController::InvalidAuthenticityToken',
        'CGI::Session::CookieStore::TamperedWithCookie',
        'ActionController::UnknownAction',
        'AbstractController::ActionNotFound',
        'Mongoid::Errors::DocumentNotFound'
      ].freeze
  end
  def NOTIFY_EXCEPTION(*args)
    Sentry.capture_exception(*args)
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
