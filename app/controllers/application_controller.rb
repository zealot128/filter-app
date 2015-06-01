class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter do
    if request.host == 'hrfilter.de'
      url = 'http://www.hrfilter.de' + request.env['REQUEST_URI']
      redirect_to url, status:  :moved_permanently
    end
  end
end
