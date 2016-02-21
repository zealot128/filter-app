if Rails.env.production?
  Baseapp::Application.config.middleware.use ExceptionNotification::Rack,
                                             email: {
                                               email_prefix: "[#{Setting.get('short_name')}] ",
                                               sender_address: %{"notifier" <#{Setting.get('from')}>},
                                               exception_recipients: [Setting.get('email')],
                                               ignore_exceptions: ['ActionController::BadRequest'] + ExceptionNotifier.ignored_exceptions,
                                               ignore_crawlers: true
                                             }
end
