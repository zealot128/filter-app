class RemoveGplusLinkedin < ActiveRecord::Migration[6.0]
  def change
    remove_column :news_items, :gplus
    remove_column :news_items, :linkedin
  end
end
