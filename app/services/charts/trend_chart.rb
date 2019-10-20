module Charts
  class TrendChart
    def initialize(trend, time_window: 2.years.ago)
      @trend = trend
      @source_trend = @trend.words.joins(:usages).
        where('date > ?', time_window).
        group_by_week('trends_usages.date').count('distinct(source_id)').delete_if { |_k, v| v == 0 }
      @ni_trend = @trend.words.joins(:usages).
        where('date > ?', time_window).
        group_by_week('trends_usages.date').count('distinct(news_item_id)').delete_if { |_k, v| v == 0 }
    end

    def to_highcharts
      p = @source_trend.map { |date, _count| date }
      min = p.min
      max = p.max
      year_df = max.year - min.year
      {
        chart: {
          type: 'column',
          zoomType: 'x'
        },
        yAxis: [
          {
            title: { text: "Quellen" },
          },
          {
            title: { text: "Beiträge" },
            opposite: true
          },
        ],
        tooltip: {
          shared: true,
          borderRadius: 0,
          pointFormat: '<b>{point.y} {series.name} </b>'
        },
        xAxis: {
          plotLines: year_df.times.map { |i| max.year - i }.map { |year|
            {
              value: Date.new(year, 1, 1).to_datetime.to_i * 1000,
              label: { text: year.to_s, fontSize: '8px' },
              width: 2
            }
          },
          type: 'datetime',
          # categories: (@source_trend.keys + @ni_trend.keys).uniq.sort,
          labels: {
            style: { fontSize: '8px' }
          }
        },
        legend: { enabled: false },
        credits: { enabled: false },
        title: {
          text: "Beiträge zum Thema in den letzten 2 Jahren",
          floating: true,
          style: {
            color: "#333333",
            fontSize: "18px"
          }
        },
        series: [
          {
            data: @source_trend.map { |date, count|
              [
                date.to_datetime.to_i * 1000,
                count
              ]
            },
            name: 'Quellen'
          },
          {
            yAxis: 1,
            data: @ni_trend.map { |date, count|
              [
                date.to_datetime.to_i * 1000,
                count
              ]
            },
            name: 'Beiträge'
          }
        ]
      }
    end
  end
end
