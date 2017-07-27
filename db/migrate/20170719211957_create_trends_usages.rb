class CreateTrendsUsages < ActiveRecord::Migration[5.2]
  def change
    create_table :trends_usages do |t|
      t.integer :word_id, index: true
      t.belongs_to :news_item, index: true, foreign_key: true
      t.belongs_to :source, index: true, foreign_key: true
      t.string :calendar_week
    end
  end
end
