class AddSearchVector < ActiveRecord::Migration
  def change
    add_column :news_items, :search_vector, :tsvector
    add_index :news_items, :search_vector, using: :gin
  end
end
