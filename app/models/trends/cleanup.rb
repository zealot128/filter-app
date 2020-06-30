module Trends
  class Cleanup
    def self.run
      cutoff = 3.months.ago.strftime("%Y%V")
      Trends::Usage.where('calendar_week < ?', cutoff).joins(:word).where('trend_id is null').in_batches(of: 10000) { |i| print '.'; i.delete_all }

      Trends::Word.left_joins(:usages).where('trends_usages.id is null').in_batches(of: 10000) { |i| i.delete_all }
    end
  end
end
