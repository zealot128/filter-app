class AddRedditToNewsItems < ActiveRecord::Migration
  def change
    add_column :news_items, :reddit, :integer
  end
end
