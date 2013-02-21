class AddGplusToNewsItems < ActiveRecord::Migration
  def change
    add_column :news_items, :gplus, :integer
  end
end
