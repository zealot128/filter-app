module Charts
  class SourceTimeChart
    def initialize(source, news_items: source.news_items)
      @source = source
      @news_items = news_items.reorder!
    end

    def show?
      @news_items.any?
    end

    def to_highcharts
      {
        chart: {
          type: 'column'
        },
        yAxis: {
          title: { text: nil },
          visible: false
        },
        tooltip: {
          shared: true,
          borderRadius: 0,
          pointFormat: '<b>{point.y} Beiträge</b>'
        },
        xAxis: {
          categories: true,
          labels: {
            style: { fontSize: '8px' }
          }
        },
        legend: { enabled: false },
        credits: { enabled: false },
        title: {
          text: "Beiträge in den letzten 2 Jahren",
          floating: true,
          style: {
            color: "#333333",
            fontSize: "18px"
          }
        },
        series: [
          {
            data:
          }
        ]
      }
    end

    def data
      couples = @news_items.group('to_char( published_at, \'YYYY/MM\')').where('published_at > ?', 25.months.ago).count
      Array.new(24) { |i| i.month.ago.strftime('%Y/%m') }.each do |month|
        couples[month] ||= 0
      end
      couples.sort_by { |k, _v| k }
    end
  end
end
