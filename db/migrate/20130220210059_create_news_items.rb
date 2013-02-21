class CreateNewsItems < ActiveRecord::Migration
  def change
    create_table :news_items do |t|
      t.string :title
      t.string :teaser
      t.string :url
      t.belongs_to :source
      t.datetime :published_at
      t.integer :value
      t.integer :fb_likes
      t.integer :retweets
      t.string :guid
      t.integer :linkedin
      t.integer :xing

      t.timestamps
    end
    add_index :news_items, :source_id
    add_index :news_items, :guid
  end
end
