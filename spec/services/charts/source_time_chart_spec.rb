require 'spec_helper'

module Charts
  describe SourceTimeChart do
    specify "doesnt blow up" do
      ni = Fabricate(:news_item)
      chart = SourceTimeChart.new(ni.source)
      expect(chart.show?).to be == true
      expect(chart.to_highcharts).to be_kind_of Hash
      expect(chart.data.map(&:second).sum).to be == 1
    end
  end
end
