class AddUsageTypeToTrendsUsages < ActiveRecord::Migration[5.2]
  def change
    add_column :trends_usages, :usage_type, :integer, default: 0
    add_index :trends_usages, :usage_type
  end
end
