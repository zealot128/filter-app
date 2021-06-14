class JobsController < ApplicationController
  def index
    response = Rails.cache.fetch("hrfilter.#{Setting.jobs_url}", expires_in: 10.minutes) {
      HTTParty.get(Setting.jobs_url)['jobs']
    }
    @jobs = response.shuffle
    # render layout: false
    render json: @jobs
  end
end
