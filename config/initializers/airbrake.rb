if Rails.application.secrets.airbrake_url.present?
  IGNORE_DEFAULT_EXCEPTIONS = ['ActiveRecord::RecordNotFound',
                               'ActionController::RoutingError',
                               'ActionController::InvalidAuthenticityToken',
                               'CGI::Session::CookieStore::TamperedWithCookie',
                               'ActionController::UnknownAction',
                               'AbstractController::ActionNotFound',
                               'Mongoid::Errors::DocumentNotFound'].freeze
  Airbrake.configure do |config|
    config.host = Rails.application.secrets.airbrake_url
    config.project_id = 1 # required, but any positive integer works
    config.project_key = Rails.application.secrets.airbrake_project_key
    # Uncomment for Rails apps
    config.environment = Rails.env
    config.ignore_environments = %w(development test)
  end
  Airbrake.add_filter do |notice|
    if notice[:errors].any? { |error| IGNORE_DEFAULT_EXCEPTIONS.include?(error[:type]) }
      notice.ignore!
    end
  end
end
