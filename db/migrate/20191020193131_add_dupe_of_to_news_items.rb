class AddDupeOfToNewsItems < ActiveRecord::Migration[6.0]
  def change
    add_column :news_items, :dupe_of_id, :integer
    add_index :news_items, :dupe_of_id
  end
end
