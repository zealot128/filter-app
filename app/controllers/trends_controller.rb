class TrendsController < ApplicationController
  # Trends of last N days
  def index
    count = (Setting.get('trend_min_sources_count') || 4).to_i
    days7 = Trends::Trend.top_of_n_days(7.days.ago, count)
    days30 = Trends::Trend.top_of_n_days(30.days.ago, count)

    render json: {
      'week' => days7.map { |i| i.as_json.except("updated_at", "created_at") },
      'month' => days30.map { |i| i.as_json.except("updated_at", "created_at") },
      #  Testen
      'all' => Trends::Trend.all.map { |i| i.as_json.except("updated_at", "created_at") },
    }
  end

  def show
    @trend = Trends::Trend.find_by!(slug: params[:slug])

    @chart = Charts::TrendChart.new(@trend)
    @page_keywords = [@trend.name] + @trend.words.map(&:word)
    count = Rails.cache.fetch("trends.#{@trend.id}.count", expires_in: 1.day) {
      @trend.words.joins(:usages).count('distinct(news_item_id)')
    }
    @page_description = "#{count} News zum Thema/Trend \"#{@trend.name}\""
  end
end
