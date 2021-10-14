class JobsController < ApplicationController
  def index
    response = Rails.cache.fetch("hrfilter.#{Setting.jobs_url}", expires_in: 10.minutes) {
      HTTParty.get(Setting.jobs_url)['jobs']
    }
    @jobs = response.shuffle
    # render layout: false
    render json: @jobs
  end

  def events
    render json:
      AdLogic.promoted_events.map { |event| 
        {
          from: event.from,
          url: event.url,
          image: event.image,
          title: event.title,
          from: event.from.strftime('Am %d.%m.%Y um %H:%M Uhr'),
        }
      }
  end
end
