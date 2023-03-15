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
    events = AdLogic.promoted_events.map { |event|
      {
        url: event.url,
        image: event.image,
        title: event.title,
        from: event.from.strftime('Am %d.%m.%Y um %H:%M Uhr'),
      }
    }.as_json
    render json: events.to_json
  end
end
