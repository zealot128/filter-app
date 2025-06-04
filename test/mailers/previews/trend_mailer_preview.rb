class TrendMailerPreview < ActionMailer::Preview
  def week
    all = Trends::Word.
      where(trends_usages: { calendar_week: 7.days.ago.strftime("%G%W") }).
      where(ignore: false).
      joins(:usages).
      group(:id).
      order('count desc').
      having('count(distinct source_id) >= 2').
      limit(25).
      select("trends_words.*, count(distinct source_id) as count")
    words = []
    words += all.trigram
    words += all.bigram
    words += all.single
    TrendMailer.week_trends(words)
  end
end
