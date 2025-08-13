class CreateWeeklySummaries < ActiveRecord::Migration[7.2]
  def change
    create_table :weekly_summaries do |t|
      t.date :week_start, null: false
      t.json :summary
      t.json :metadata

      t.timestamps
    end
    
    add_index :weekly_summaries, :week_start, unique: true
  end
end
