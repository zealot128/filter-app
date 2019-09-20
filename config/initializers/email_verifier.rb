EmailVerifier.config do |config|
  config.test_mode = !Rails.env.production?
  begin
    config.verifier_email = Setting.get('from')
  rescue StandardError # rubocop:disable Lint/HandleExceptions
    # Settings noch nicht verfügbar
  end

  config.ignore_failure_on do |exception, email|
    if Rails.env.development?
      p exception
      true
    else
      Airbrake.notify(exception, email: email.split('@').last)
      !!exception.to_s['Failure']
    end
  end
end
