class AddDupeToTrendsUsages < ActiveRecord::Migration[6.0]
  def change
    add_column :trends_usages, :dupe, :boolean, default: false
    add_index :trends_usages, :dupe
  end
end
