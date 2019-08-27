class AppController < ApplicationController
  def index
    @title = "#{Setting.site_name}-App auf Ihrem Smartphone"
  end
end
