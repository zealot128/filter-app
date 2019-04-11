class AddWeightToCategoriesNewsItems < ActiveRecord::Migration[5.2]
  def change
    add_column :news_items, :category_order, :integer, array: true
  end
end
