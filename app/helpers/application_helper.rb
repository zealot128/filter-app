module ApplicationHelper
  def page_title
    [ @title, Configuration.site_name].reject(&:blank?).join(' | ')
  end
  def homepage(url)
    URI.parse(url).tap{|o| o.path = '/'; o.query =nil}.to_s
  end
  def day_path(day)
    raw_day_path(year: day.year, month: "%02d" % day.month, day: "%02d" % day.day)
  end
end
