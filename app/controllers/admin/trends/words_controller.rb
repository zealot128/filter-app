class Admin::Trends::WordsController < AdminController
  load_and_authorize_resource class: 'Trends::Word'

  def index
    @week = (params[:week] || 0).to_i.weeks.ago.strftime("%G%W")
    @title = "Trendfinder #{@week}"
    words! Trends::Word.
      where('trends_usages.calendar_week = ?', @week)
    @trends = Trends::Trend.includes(:words).all
  end

  def months
    @month = (params[:month] || 0).to_i.month.ago

    @title = "Trendfinder #{@month.strftime('%m %Y')}"

    words! Trends::Word.
      where('trends_usages.date between ? and ?', @month.at_beginning_of_month.to_date, @month.at_end_of_month.to_date)
    @trends = Trends::Trend.includes(:words).all
  end

  def ignore
    @word.update(ignore: true)
  end

  private

  def words!(scope)
    base = scope.
      where(ignore: false).
      joins(:usages).
      group(:id).
      order('count desc').
      having('count(distinct source_id) >= 2').
      limit(50).
      select("trends_words.*, count(distinct source_id) as count")
    @top_trigram = base.trigram
    @top_bigram = base.bigram
    @top_single = base.single

  end
end
