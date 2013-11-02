class AddFullTextToNewsItems < ActiveRecord::Migration
  def change
    add_column :news_items, :full_text, :text
  end
end
