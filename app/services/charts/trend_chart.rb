module Charts
  class TrendChart
    def initialize(trend)
      @trend = trend
      @source_trend = @trend.words.joins(:usages).
        where('date > ?', 2.years.ago).
        group_by_day('trends_usages.date').count('distinct(source_id)').delete_if { |_k, v| v == 0 }
      @ni_trend = @trend.words.joins(:usages).
        where('date > ?', 2.years.ago).
        group_by_day('trends_usages.date').count('distinct(news_item_id)').delete_if { |_k, v| v == 0 }
    end

    def to_highcharts
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
