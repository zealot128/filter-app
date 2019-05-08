class JobsController < ApplicationController
  def index
    response = Rails.cache.fetch("hrfilter.#{Setting.jobs_url}", expires_in: 10.minutes) {
      resp = HTTParty.get(Setting.jobs_url + "&with_facets=true")
      {
        jobs: resp['jobs'],
        facets: resp['facets']
      }
    }
    @jobs = response[:jobs].shuffle
    @locations = response[:facets]['location_names'].keys
    render layout: false
  end
end
