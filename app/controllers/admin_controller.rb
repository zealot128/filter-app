# :nocov:
class AdminController < ApplicationController
  before_action do
    if ActionController::HttpAuthentication::Basic.has_basic_credentials?(request) and request.format.json?
      username, password = ActionController::HttpAuthentication::Basic.user_name_and_password(request)
      if Rails.application.secrets.http_username == username && Rails.application.secrets.http_password == password
        sign_in User.first
        @sign_out_after = true
        request.env['rack.session.options'][:skip] = true
      else
        render status: 401, text: "Unauthenticated"
      end
    end
  end

  before_action :authenticate_user!
  check_authorization

  rescue_from CanCan::AccessDenied do |ex|
    redirect_to '/', notice: "Kein Zugriff auf #{ex.action}->#{ex.subject}"
  end
end
