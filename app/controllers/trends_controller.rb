class TrendsController < ApplicationController
  # Trends of last N days
  def index
    days7 = Trends::Trend.top_of_n_days(7.days.ago, 4)
    days30 = Trends::Trend.top_of_n_days(30.days.ago, 4)

    render json: {
      'week' => days7.map { |i| i.as_json.except("updated_at", "created_at") },
      'month' => days30.map { |i| i.as_json.except("updated_at", "created_at") }
    }
  end

  def show
    @trend = Trends::Trend.find_by!(slug: params[:slug])

    @chart = Charts::TrendChart.new(@trend)
  end
end
