class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter do
    if request.host == Setting.host.remove('www.', '') and Rails.env.production?
      url = "https://#{Setting.host}" + request.env['REQUEST_URI']
      redirect_to url, status:  :moved_permanently
    end
  end
end
