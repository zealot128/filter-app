class AddYoutubeStarsToNewsItems < ActiveRecord::Migration
  def change
    add_column :news_items, :youtube_likes, :integer, default: 0
    add_column :news_items, :youtube_views, :integer, default: 0
  end
end
