# :nocov:
class AdminController < ApplicationController
  http_basic_authenticate_with name: Rails.application.secrets.http_username, password: Rails.application.secrets.http_password
end
