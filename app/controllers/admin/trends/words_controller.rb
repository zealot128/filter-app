class Admin::Trends::WordsController < AdminController
  load_and_authorize_resource class: 'Trends::Word'

  def index
    @week = (params[:week] || 0).to_i.weeks.ago.strftime("%G%W")
    base = Trends::Word.all.where(ignore: false).joins(:usages).where('trends_usages.calendar_week = ?', @week).
      group(:id).order('count desc').having('count(distinct source_id) > 2').limit(50).select("trends_words.*, count(distinct source_id) as count")
    @top_trigram = base.trigram
    @top_bigram = base.bigram
    @top_single = base.single
    @trends = Trends::Trend.includes(:words).all
  end

  def ignore
    @word.update(ignore: true)
  end
end
