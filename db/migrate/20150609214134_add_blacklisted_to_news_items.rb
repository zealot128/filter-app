class AddBlacklistedToNewsItems < ActiveRecord::Migration
  def change
    add_column :news_items, :blacklisted, :boolean, default: false
  end
end
