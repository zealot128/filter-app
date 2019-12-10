# rubocop:disable Naming/MethodName
if ENV['SENTRY_DSN']
  SENTRY_RELEASE = if File.exist?("GIT_REVISION")
                     File.read("GIT_REVISION")
                   else
                     ""
                   end
  require 'sentry-raven'
  Raven.configure do |config|
    # config.dsn = ENV['SENTRY_DSN']
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
    config.environments = %w[production]
    config.release = SENTRY_RELEASE
    if ENV['SENTRY_DSN'].include?('sentry.pludoni')
      config.processors -= [Raven::Processor::PostData] # Do this to send POST data
      config.processors -= [Raven::Processor::Cookies] # Do this to send cookies by default
    end
    config.excluded_exceptions =
      Raven::Configuration::IGNORE_DEFAULT + [
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
    Raven.capture_exception(*args)
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
