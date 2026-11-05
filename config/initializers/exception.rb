# rubocop:disable Naming/MethodName
dsn = Rails.application.credentials.dig(:sentry_dsn) || ENV.fetch('SENTRY_DSN', nil)
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
    # data_collection-Default (sentry >= 7) sammelt PII; nur fremde DSNs restriktiv wie früher ohne send_default_pii
    config.data_collection = Sentry::DataCollection.backfill(config) unless dsn.include?('sentry.pludoni')
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    # Sentry >= 6 verwirft Events, wenn before_send kein Event zurückgibt -> in-place filtern
    config.before_send = ->(event, _hint) do
      event.request.data = filter.filter(event.request.data) if event.request&.data.is_a?(Hash)
      event.extra = filter.filter(event.extra)
      event
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
