class Ahoy::Store < Ahoy::DatabaseStore
end

module AhoyPatch
  def visit_anonymity_set
    @visit_anonymity_set ||= Digest::UUID.uuid_v5(Ahoy::Tracker::UUID_NAMESPACE, ["visit", Ahoy.mask_ip(request.remote_ip), request.user_agent, ENV['USER']].join("/"))
  end
end
Ahoy::Tracker.prepend(AhoyPatch)

# set to true for JavaScript tracking
Ahoy.api = false

# better user agent parsing
Ahoy.user_agent_parser = :device_detector
Ahoy.server_side_visits = true
Ahoy.job_queue = :low_priority
Ahoy.mask_ips = true
Ahoy.cookies = false
Ahoy.quiet = Rails.env.production?
Ahoy.geocode = false

Rollup.week_start = :monday
