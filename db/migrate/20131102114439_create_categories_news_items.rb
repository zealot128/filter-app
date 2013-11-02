class CreateCategoriesNewsItems < ActiveRecord::Migration
  def change
    create_table :categories_news_items, :id => false do |t|
      t.references :category, :news_item
    end

    add_index :categories_news_items, [:category_id, :news_item_id],
      name: "categories_news_items_index",
      unique: true
  end
end
