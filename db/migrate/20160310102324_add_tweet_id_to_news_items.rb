class AddTweetIdToNewsItems < ActiveRecord::Migration
  def change
    add_column :news_items, :tweet_id, :string
  end
end
