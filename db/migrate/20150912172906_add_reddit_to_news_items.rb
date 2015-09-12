class AddRedditToNewsItems < ActiveRecord::Migration
  def change
    add_column :news_items, :reddit, :intege
  end
end
