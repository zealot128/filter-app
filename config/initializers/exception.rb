if Rails.env.production?
  Baseapp::Application.config.middleware.use ExceptionNotification::Rack,
    email: {
    :email_prefix => "[#{Configuration.short_name}] ",
    :sender_address => %{"notifier" <#{Configuration.from}>},
    :exception_recipients => [Configuration.email],
    ignore_exceptions: ['ActionController::BadRequest'] + ExceptionNotifier.ignored_exceptions,
    ignore_crawlers: true
  }
end
