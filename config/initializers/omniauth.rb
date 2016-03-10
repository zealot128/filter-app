
Rails.application.config.middleware.use OmniAuth::Builder do
  s = Rails.application.secrets
  provider :twitter, s.twitter_consumer_key, s.twitter_consumer_secret
end
