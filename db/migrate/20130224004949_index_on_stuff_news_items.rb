class IndexOnStuffNewsItems < ActiveRecord::Migration
  def change
    add_index :news_items, :value
    add_index :news_items, :published_at
  end
end
