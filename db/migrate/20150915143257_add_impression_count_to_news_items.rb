class AddImpressionCountToNewsItems < ActiveRecord::Migration
  def change
    add_column :news_items, :impression_count, :integer, default: 0
  end
end
