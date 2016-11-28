Rack::Attack.blocklist('fail2ban pentesters') do |req|
  # `filter` returns truthy value if request fails, or if it's from a previously banned IP
  # so the request is blocked
  Rack::Attack::Fail2Ban.filter("pentesters-#{req.ip}", maxretry: 3, findtime: 10.minutes, bantime: 15.minutes) do
		qs = CGI.unescape(req.query_string)
    #  # The count for the IP is incremented if the return value is truthy
    qs.include?("'A=0") || qs =~ %r{/etc/passwd|/proc/self|/etc/hosts} ||
      req.path.include?('/etc/passwd') ||
      req.path.include?('/etc/passwd') ||
      req.path.include?('wp-admin') ||
      req.path.include?('wp-login')
    #
  end
end
