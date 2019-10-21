class Admin::Trends::WordsController < AdminController
  load_and_authorize_resource class: 'Trends::Word'

  def index
    @week = (params[:week] || 0).to_i.weeks.ago.strftime("%G%W")
    @title = "Trendfinder #{@week}"
    words! Trends::Word.
      where('trends_usages.calendar_week = ?', @week)
    @trends = Trends::Trend.includes(:words).order('name')
  end

  def months
    @month = (params[:month] || 0).to_i.month.ago

    @title = "Trendfinder #{@month.strftime('%m %Y')}"

    words! Trends::Word.
      where('trends_usages.date between ? and ?', @month.at_beginning_of_month.to_date, @month.at_end_of_month.to_date)
    @trends = Trends::Trend.includes(:words).order('name')
  end

  def ignore
    @word.update(ignore: true)
  end

  def merge
    @trend = Trends::Trend.find(params[:trend_id])

    @word.update(trend_id: @trend.id)
  end

  private

  def words!(scope, min: 2)
    usage_type = params[:usage_type] || 'title'
    relevant = scope.
      where(ignore: false).
      joins(:usages).
      where(trends_usages: { usage_type: Trends::Usage.usage_types[usage_type] })

    base = relevant.
      group(:id).
      order('count desc').
      having('count(distinct trends_usages.source_id) >= 3').
      limit(50).
      select("trends_words.*, count(distinct trends_usages.source_id) as count")
    @top_quadram = base.quadrogram
    @top_trigram = base.trigram
    @top_bigram = base.bigram
    @word_count = relevant.count('distinct trends_words.id')
    @news_item_count = relevant.count('distinct news_item_id')
  end
end
