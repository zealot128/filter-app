class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action do
    prepend_view_path Rails.root.join('app', 'views', Setting.key)
  end

  before_action :check_hostname_redirect

  private

  def check_hostname_redirect
    if request.host == Setting.host.remove('www.', '') and Rails.env.production?
      url = "https://#{Setting.host}" + request.env['REQUEST_URI']
      redirect_to url, status: :moved_permanently
    end
  end

  def stop_bad_crawler!
    return unless params[:page]
    if (params[:page].to_i.to_s != params[:page]) || params[:page].to_i > 150 || params[:page].to_i <= 0
      render file: 'public/400.html', status: 400, layout: false
    end
  end
end
