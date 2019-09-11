class DaysController < ApplicationController
  def index
    reference = Date.today
    if params[:date] && params[:date].to_s[/^\d{4}/]
      reference = Date.parse(params[:date])
      days = [reference]
    else
      days = 2.times.map { |i| reference - i }
    end
    @days = days.map { |date|
      all =  NewsItem.top_of_day(date)
      count = all.count
      take = [(count * 0.33).ceil, 8].max
      news = all.limit(take)
      [date, count, news]
    }
    if request.xhr?
      render partial: 'day_container', layout: false
    end
  end

  def show
    @day = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    if @day > Date.today
      raise ArgumentError
    end
    @news = NewsItem.top_of_day(@day)
    @tomorrow = @day + 1
    if @tomorrow > Date.today
      @tomorrow = nil
    end
    @yesterday = @day - 1
    respond_to do |f|
      f.html
      f.js
    end
  rescue ArgumentError
    render html: "<h3>Ungültiges Datum</h3>", layout: true, status: 400
  end
end
