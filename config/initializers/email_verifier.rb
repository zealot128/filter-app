begin
  EmailVerifier.config do |config|
    config.verifier_email = Setting.get('from')
  end
rescue Exception
end
