class SourcesGrid < BaseGrid
  scope do
    Source.limit(100).order(Arel.sql('case error when true then 0 else 1 end, name'))
  end

  def column_class(source)
    if source.deactivated?
      'deactivated active'
    elsif source.error
      'danger'
    elsif source.statistics && source.statistics['current_news_count'] == 0
      'warning'
    else
      ''
    end
  end

  filter(:name, :string) { |value, scope| scope.where("name ilike '%#{value}%'") }
  filter(:error, :xboolean)
  filter(:type, :enum, select: -> { Source.pluck(Arel.sql('distinct(type)')) }, checkboxes: true)
  filter(:deactivated, :xboolean, default: false)

  column(:id)
  column(:name) do |f|
    "<img src='#{f.logo(:small)}'/>#{f.name}".html_safe
  end
  column(:type, header: "Typ", &:source_name)
  column(:value, header: "Bias")
  column(:error, header: "Fehler", html: true) do |f|
    if f.error
      "<abbr title='#{h(f.error_message)}'>Ja</a>".html_safe
    else
      ""
    end
  end
  column(:recent, Arel.sql('statistics->\'current_news_count\''), header: "News Aktuell", order: '(statistics->>\'current_news_count\')::int')
  column(:recent_top, Arel.sql('statistics->\'current_top_score\''), header: "Top Score", order: '(statistics->>\'current_top_score\')::int')
  column(:total, Arel.sql('statistics->\'total_news_count\''), header: "News Ingesamt", order: '(statistics->>\'total_news_count\')::int')
  date_column(:last_posting, Arel.sql("(statistics->>'last_posting')::date"), order: "(statistics->>'last_posting')")
  column(:word_length, Arel.sql('statistics->\'average_word_length\''), header: "Wortlänge (Letzte 5 Beiträge)", order: '(statistics->>\'average_word_length\')::int')
  date_column(:created_at)
  column(:chart, html: true, order: '(statistics->>\'current_top_score\')::int', header: "3-Monats-Platzierung") do |source|
    content_tag(:div, nil, class: "js-recent-chart", data: { id: source.id }, style: 'height: 100px; width: 200px')
  end
  column(:actions, html: true) do |source|
    safe_join [
      content_tag(:div, class: 'btn-group') {
        safe_join [
          link_to('bearbeiten', [:edit, :admin, source.becomes(Source)], class: 'btn btn-default btn-xs'),
          link_to("löschen", [:admin, source.becomes(Source)], class: 'btn btn-default btn-xs', data: { method: :delete, confirm: 'really?' }),
          link_to("source-page", source_path(source), class: 'btn btn-xs btn-default'),
          link_to("feed-url", source.url, class: 'btn btn-xs btn-primary'),
        ]
      },
      content_tag(:div) {
        safe_join [
          content_tag(:small, "Refresh: "),
          content_tag(:div, class: 'btn-group') {
            safe_join [
              link_to("Quelle", refresh_admin_source_path(source, type: 'source'), data: { method: :post, remote: true, disable_with: '...' }, class: 'btn btn-xs btn-primary', title: "Quelle jetzt abrufen"),
              link_to("letzte 10 News", refresh_admin_source_path(source, type: 'news_items'), data: { method: :post, remote: true, disable_with: '...' }, class: 'btn btn-xs btn-primary', title: "Letzte bereits angelegte NewsItems auf Scoring prüfen (Twitter shares, etc.)")
            ]
          }
        ]
      }
    ]
  end
end
