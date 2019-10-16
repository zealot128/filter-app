class TrendsController < ApplicationController
  def show
    @trend = Trends::Trend.find_by!(slug: params[:slug])

    @chart = Charts::TrendChart.new(@trend)
  end
end
