class AddTrendMinSourceCountToSettings < ActiveRecord::Migration[6.0]
  def change
     Setting.set('trend_min_sources_count', 4)
  end
end
