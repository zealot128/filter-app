class SourcesGrid < BaseGrid
  scope do
    Source.limit(100).order('case error when true then 0 else 1 end, name')
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
  filter(:created_at, :date, range: true)
  filter(:type, :enum, select: -> { Source.pluck('distinct(type)') }, checkboxes: true)

  column(:id)
  column(:name) do |f|
    "<img src='#{f.logo(:small)}'/>#{f.name}".html_safe
  end
  column(:type, header: "Typ", &:source_name)
  column(:value, header: "Bias")
  column(:error, header: "Fehler") do |f|
    if f.error
      "Ja"
    else
      ""
    end
  end
  column(:recent, 'statistics->\'current_news_count\'', header: "News Aktuell", order: '(statistics->>\'current_news_count\')::int')
  column(:total, 'statistics->\'total_news_count\'', header: "News Ingesamt", order: '(statistics->>\'total_news_count\')::int')
  date_column(:last_posting, '(select max(published_at) from news_items where news_items.source_id = sources.id)', order: 'last_posting')
  column(:average_word_length)
  date_column(:created_at)
  column(:actions, html: true) do |source|
    safe_join [
      content_tag(:div, class: 'btn-group') {
        safe_join [
          link_to('bearbeiten', [:edit, :admin, source.becomes(Source)], class: 'btn btn-default btn-xs'),
          link_to("löschen", [:admin, source.becomes(Source)], class: 'btn btn-default btn-xs', data: { method: :delete, confirm: 'really?' }),
          link_to("feed-url", source.url, class: 'btn btn-xs btn-primary'),
        ]
      },
      content_tag(:div) {
        safe_join [
          content_tag(:small, "Refresh: "),
          content_tag(:div, class: 'btn-group') {
            safe_join [
              link_to("Quelle", refresh_admin_source_path(source, type: 'source'), data: { method: :post, remote: true, disable_with: '...' }, class: 'btn btn-xs btn-primary'),
              link_to("letzte 10 News", refresh_admin_source_path(source, type: 'news_items'), data: { method: :post, remote: true, disable_with: '...' }, class: 'btn btn-xs btn-primary')
            ]
          }
        ]
      }
    ]
  end
end
