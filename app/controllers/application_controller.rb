class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter do
    if request.host == ::Configuration.host.remove('www.', '') and Rails.env.production?
      url = "http://#{::Configuration.host}" + request.env['REQUEST_URI']
      redirect_to url, status:  :moved_permanently
    end
  end
end
