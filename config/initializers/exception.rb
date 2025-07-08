# rubocop:disable Naming/MethodName
dsn = Rails.application.credentials.dig(:sentry_dsn) || ENV['SENTRY_DSN']
if dsn
  SENTRY_RELEASE = if File.exist?("GIT_REVISION")
                     File.read("GIT_REVISION")
                   else
                     ""
                   end
  Sentry.init do |config|
    config.dsn = dsn
    config.enabled_environments = %w[production]
    config.release = SENTRY_RELEASE
    if dsn.include?('sentry.pludoni')
      config.send_default_pii = true
    end
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    config.before_send = ->(event, _hint) do
      filter.filter(event.to_hash)
    end
    config.excluded_exceptions =
      Sentry::Configuration::IGNORE_DEFAULT + [
        'ActiveRecord::RecordNotFound',
        'ActionController::RoutingError',
        'ActionController::InvalidAuthenticityToken',
        'CGI::Session::CookieStore::TamperedWithCookie',
        'ActionController::UnknownAction',
        'AbstractController::ActionNotFound',
        'Mongoid::Errors::DocumentNotFound'
      ].freeze
  end
  def NOTIFY_EXCEPTION(*)
    Sentry.capture_exception(*)
  end

else
  def NOTIFY_EXCEPTION(*args)
  end

end

def CATCH_ALL(&)
  yield
rescue StandardError => e
  NOTIFY_EXCEPTION(e)
  raise e
end
