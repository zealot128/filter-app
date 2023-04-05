module Charts
  class SourceScoreChart
    def initialize(source, max: 2.years.ago)
      @source = source
      @news_items = source.news_items.where('published_at > ?', max).order('published_at').where('absolute_score > 0')

      @benchmark =
        Rails.cache.fetch("benchmark.#{max.to_date}", expires_in: 1.day) do
          NewsItem.where('published_at > ?', max).where('absolute_score > 0').
            group_by_month(:published_at).
            pluck(
              Arel.sql("(DATE_TRUNC('month', (\"news_items\".\"published_at\"::timestamptz) AT TIME ZONE 'Etc/UTC'))::date AT TIME ZONE 'Etc/UTC' as month"),
              Arel.sql("PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY absolute_score) as q1"),
              Arel.sql("PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY absolute_score) as median"),
              Arel.sql("PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY absolute_score) as q3"),
              Arel.sql("PERCENTILE_CONT(0.90) WITHIN GROUP(ORDER BY absolute_score) as q9"),
              Arel.sql("max(absolute_score) as max")
            )
        end
    end

    def to_highcharts
      {
        chart: {
          zoomType: 'x'
        },
        plotOptions: {
          series: {
            animation: false,
          }
        },
        yAxis: {
          title: { text: nil },
          visible: false
        },
        tooltip: {
          shared: true,
          borderRadius: 0,
          pointFormat: '<b>Score: {point.y}</b> '
        },
        xAxis: {
          type: 'datetime',
          labels: {
            style: { fontSize: '8px' }
          }
        },
        credits: { enabled: false },
        title: {
          text: "Avg Score der Beiträge",
          floating: true,
          style: {
            color: "#993333",
            fontSize: "18px"
          }
        },
        series: [
          {
            data: @benchmark.flat_map { |d, q1, median, q3, q9, max| [[d.to_i * 1000, q9.round], [(d.at_end_of_month).to_i * 1000, q9.round]]},
            name: "Q90%",
            color: '#cc999977',
            type: 'area'
          },
          {
            data: @benchmark.flat_map { |d, q1, median, q3, q9, max| [[d.to_i * 1000, q3.round], [(d.at_end_of_month).to_i * 1000, q3.round]]},
            name: "Q3",
            color: '#aa999955',
            type: 'area'
          },
          {
            data: @benchmark.flat_map { |d, q1, median, q3, q9, max| [[d.to_i * 1000, median.round], [(d.at_end_of_month).to_i * 1000, median.round]]},
            name: "Median",
            color: '#99999955',
            type: 'area'
          },
          {
            data: @news_items.pluck('published_at, absolute_score').map { |d, s| [d.to_i * 1000, s&.round(1) || 0] },
            name: "Einzelbeiträge der Quelle",
            color: '#00000',
            marker: {
              radius: 2,
              symbol: 'circle',
            },
            type: 'scatter'
          },
        ]
      }
    end
  end
end
