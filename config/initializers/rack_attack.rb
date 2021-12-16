Rack::Attack.blocklist('fail2ban pentesters') do |req|
  Rack::Attack::Fail2Ban.filter("pentesters-#{req.ip}", maxretry: 3, findtime: 10.minutes, bantime: 15.minutes) do
    qs = CGI.unescape(req.query_string)
    qs.include?("'A=0") || qs =~ %r{/etc/passwd|/proc/self|/etc/hosts}
      req.path.include?('/etc/passwd') ||
      req.path.include?('wp-admin') ||
      req.path.include?('wp-login') ||
      req.path.include?('.php')
  end
end

Rack::Attack.throttle("newsletter", limit: 3, period: 5.minutes) do |req|
  if req.post? and req.path.starts_with?("/newsletter")
    req.ip
  end
end

Rack::Attack.throttle("newsletter_ever", limit: 100, period: 1.week) do |req|
  if req.post? and req.path.starts_with?("/newsletter")
    req.ip
  end
end

Rack::Attack.blocklist("Newsletter Subscriber mit fragwürdigen E-Mail Domains blockieren") do |req|
  if req.post? && req.params.to_s.match?(/online\.co|comcast\.net|libero\.it/i)
    req.ip
  end
end


Rack::Attack.enabled = !Rails.env.test? 

Rack::Attack.blocklist_ip("176.49.9.157")

Rack::Attack.throttled_response = lambda do |request|
  # NB: you have access to the name and other data about the matched throttle
  #  request.env['rack.attack.matched'],
  #  request.env['rack.attack.match_type'],
  #  request.env['rack.attack.match_data'],
  #  request.env['rack.attack.match_discriminator']

  # Using 503 because it may make attacker think that they have successfully
  # DOSed the site. Rack::Attack returns 429 for throttling by default
  [ 503, { 'Content-Type' => 'text/html; encoding=utf-8'}, [File.read('public/503.html')]]
end
