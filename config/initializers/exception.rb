if Rails.env.production?
  Baseapp::Application.config.middleware.use ExceptionNotification::Rack,
                                             email: {
                                               email_prefix: "[#{Setting.short_name}] ",
                                               sender_address: %{"notifier" <#{Setting.get('from')}>},
                                               exception_recipients: [Setting.email],
                                               ignore_exceptions: ['ActionController::BadRequest'] + ExceptionNotifier.ignored_exceptions,
                                               ignore_crawlers: true
                                             }
end
