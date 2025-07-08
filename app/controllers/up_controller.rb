# TODO: Rails 8.0
class UpController < ApplicationController
  skip_before_action :check_hostname_redirect

  def index
    head :ok
  end
end
