class CreateTrendsTrends < ActiveRecord::Migration[6.0]
  def change
    create_table :trends_trends do |t|
      t.string :name

      t.timestamps
    end
    add_column :trends_words, :trend_id, :integer
    add_index :trends_words, :trend_id
  end
end
