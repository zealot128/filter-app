class AddTrendDateIndex < ActiveRecord::Migration[6.0]
  def change
    add_index :trends_usages, :date
    add_index :trends_usages, :calendar_week
  end
end
