if Rails.env.production?
  Baseapp::Application.config.middleware.use ExceptionNotification::Rack,
    email: {
    :email_prefix => "[HRfilter] ",
    :sender_address => %{"notifier" <info@hrfilter.de>},
    :exception_recipients => %w{info@stefanwienert.de}
  }
end
