class AddTrendAnalyzedToNewsItems < ActiveRecord::Migration[6.0]
  def change
    add_column :news_items, :trend_analyzed, :boolean, default: false
  end
end
