EmailVerifier.config do |config|
  begin
    config.verifier_email = Setting.get('from')
  rescue Exception
    # Settings noch nicht verfügbar
  end

  config.ignore_failure_on do |exception, email|
    if Rails.env.development?
      p exception
    else
      Airbrake.notify(exception, email: email.split('@').last)
    end

    !!exception.to_s['Failure']
  end
end
