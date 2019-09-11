# :nocov:
class AdminController < ApplicationController
  before_action :authenticate_user!
  check_authorization

  rescue_from CanCan::AccessDenied do |ex|
    redirect_to '/', notice: "Kein Zugriff auf #{ex.action}->#{ex.subject}"
  end
end
