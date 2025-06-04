module Charts
  describe SourceTimeChart do
    specify "doesnt blow up" do
      ni = Fabricate(:news_item, published_at: 3.months.ago)
      chart = SourceTimeChart.new(ni.source)
      expect(chart.show?).to be == true
      expect(chart.to_highcharts).to be_kind_of Hash
      expect(chart.data.sum(&:second)).to be == 1
    end
  end
end
