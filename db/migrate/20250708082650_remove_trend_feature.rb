class RemoveTrendFeature < ActiveRecord::Migration[7.2]
  def change
    # Drop trend-related tables
    drop_table :trends_trends, if_exists: true
    drop_table :trends_usages, if_exists: true
    drop_table :trends_words, if_exists: true
    drop_table :categories_trends_words, if_exists: true
    
    # Remove trend-related columns from other tables
    remove_column :news_items, :trend_analyzed, :boolean if column_exists?(:news_items, :trend_analyzed)
    remove_column :settings, :trend_min_source_count, :integer if column_exists?(:settings, :trend_min_source_count)
    remove_column :categories, :trend_category, :boolean if column_exists?(:categories, :trend_category)
  end
end
