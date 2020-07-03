module ApplicationHelper
  def page_title
    [@title, Setting.site_name].reject(&:blank?).join(' | ')
  end

  def default_meta_tags
    {
      title: page_title,
      site: Setting.site_name,
      reverse: true,
      description: Setting.get('meta_description'),
      keywords: Setting.get('meta_keywords'),
      separator: "&mdash;".html_safe,
      image: img = image_url("#{Setting.key}/logo-large.png"),
      image_src: img,
      og: {
        title: :title,
        type: 'website',
        url: request.url,
        image: :image,
        description: :description
      },
      twitter: { image: :image_src }
    }
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

  def hashtags(string)
    string.gsub(/#(\w*[0-9a-zA-Z\p{L}]+\w*[0-9a-zA-Z\p{L}])/, '<mark class="hashtag">#\1</mark>')
  end

  # rubocop:disable LineLength
  def placeholder(setting)
    case setting
    when 'mail_intro'
      {
        "{{top}}": "Anzahl der Neuigkeiten, deren Halbwertszeit von 12.5 Std noch nicht abgelaufen ist und deren Thema ausgewählt wurde",
        "{{total_count}}": "Gesamtanzahl der Neuigkeiten, deren Thema gewählt wurde",
        "{{from_interval}}": "Je nach Einstellung der Sendungshäufigkeit folgende Zeichenfolgen: 'der letzten Woche', 'der letzten zwei Wochen' oder 'des letzten Monats'",
        "{{categories}}": "Kommagetrennte Liste mit den abonnierten Themen"
      }
    when 'mail_outro'
      {
        "{{person_email}}": "'#{Setting.get_value('person_email')}'",
        "{{abmelde_link}}": "Abmeldelink",
        "{{person}}": "'#{Setting.get_value('person')}'"
      }
    end
  end
  # rubocop:enable LineLength
end
