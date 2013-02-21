if Rails.env.production?
  Baseapp::Application.config.middleware.use ExceptionNotifier,
    :email_prefix => "[HRfilter] ",
    :sender_address => %{"notifier" <info@hrfilter.de>},
    :exception_recipients => %w{stwienert@gmail.com}
end
