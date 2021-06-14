class AddMediaUrlToNewsItem < ActiveRecord::Migration[6.0]
  def change
    add_column :news_items, :media_url, :string
  end
end