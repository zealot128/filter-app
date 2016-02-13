class DaysController < ApplicationController
  def index
    @days = 14.times.map { |i|
      date = i.days.ago.to_date
      all =  NewsItem.top_of_day(date)
      take = [(all.count * 0.33).ceil, 8].max
      news = all.limit(take)
      [ date, all.count, news]
    }
  end

  def show
    @day = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    @news = NewsItem.top_of_day(@day)
  end
end
