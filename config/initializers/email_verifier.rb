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
      should_fail = exception.to_s['Failure'] and !exception.to_s['mailbox unavailable']
      if should_fail
        NOTIFY_EXCEPTION(exception, extra: { email: email })
      end
      !!should_fail
    end
  end
end
