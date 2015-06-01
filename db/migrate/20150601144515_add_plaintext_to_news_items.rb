class AddPlaintextToNewsItems < ActiveRecord::Migration
  def change
    add_column :news_items, :plaintext, :text
  end
end
