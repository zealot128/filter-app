class AddAbsoluteScoreToNewsItems < ActiveRecord::Migration
  def change
    add_column :news_items, :absolute_score, :float
    add_index :news_items, :absolute_score
    add_index :news_items, [:absolute_score, :published_at ]
  end
end
