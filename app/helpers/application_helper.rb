module ApplicationHelper
  def page_title
    [@title, Setting.site_name].reject(&:blank?).join(' | ')
  end

  def homepage(url)
    URI.parse(url).tap { |o| o.path = '/'; o.query = nil }.to_s
  end

  def day_path(day)
    raw_day_path(year: day.year, month: "%02d" % day.month, day: "%02d" % day.day)
  end

  def bool_checkmark(bool)
    content_tag(:span, bool ? "Ja" : "Nein", class: 'sr-only') +
    content_tag(:i, nil, class: bool ? 'fa fa-check-square-o' : 'fa fa-square-o')
  end
end
