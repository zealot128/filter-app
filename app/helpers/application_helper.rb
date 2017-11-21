module ApplicationHelper
  def page_title
    [@title, Setting.site_name].reject(&:blank?).join(' | ')
  end

  def homepage(url)
    URI.parse(url).tap { |o| o.path = '/'; o.query = nil }.to_s
  end

  def day_path(day)
    raw_day_path(year: day.year, month: format("%02d", day.month), day: format("%02d", day.day))
  end

  def bool_checkmark(bool)
    content_tag(:span, bool ? "Ja" : "Nein", class: 'sr-only') +
      content_tag(:i, nil, class: bool ? 'fa fa-check-square-o' : 'fa fa-square-o')
  end

  def placeholder(setting)
    case setting
    when 'mail_intro'
      {
        "{{top}}": "Anzahl der Neuigkeiten, deren Halbwertszeit (12.5 Std) noch nicht abgelaufen ist",
        "{{total_count}}": "Gesamtanzahl der Neuigkeiten",
        "{{from_interval weekly}}": "'aus letzter Woche'",
        "{{from_interval monthly}}": "'des letzten Monats'",
        "{{from_interval biweekly}}": "'der letzten zwei Wochen'",
        "{{categories}}": "Kommagetrennte Liste mit den abonnierten Themen"
      }
    when 'mail_outro'
      {
        "{{person_email}}": "'#{Setting.get_value('person_email')}'",
        "{{person}}": "'#{Setting.get_value('person')}'",
      }
    end
  end
end
