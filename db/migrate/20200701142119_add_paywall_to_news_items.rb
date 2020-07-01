class AddPaywallToNewsItems < ActiveRecord::Migration[6.0]
  def change
    add_column :news_items, :paywall, :boolean, default: false
  end
end
