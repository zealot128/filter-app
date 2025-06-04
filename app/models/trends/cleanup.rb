module Trends
  class Cleanup
    def self.run
      cutoff = 3.months.ago.strftime("%Y%V")
      Trends::Usage.where(calendar_week: ...cutoff).joins(:word).where(trend_id: nil).in_batches(of: 10000) { |i|
        Rails.logger.debug '.'
                                                                                                                  i.delete_all
      }

      Trends::Word.left_joins(:usages).where(trends_usages: { id: nil }).in_batches(of: 10000) { |i| i.delete_all }
    end
  end
end
