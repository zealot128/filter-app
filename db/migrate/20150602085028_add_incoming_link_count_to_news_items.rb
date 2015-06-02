class AddIncomingLinkCountToNewsItems < ActiveRecord::Migration
  def change
    add_column :news_items, :incoming_link_count, :integer
  end
end
