class ChangeToText < ActiveRecord::Migration
  def change
    change_column :news_items, :teaser, :text
  end
end
