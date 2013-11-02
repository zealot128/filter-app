class AddWordLengthToNewsItems < ActiveRecord::Migration
  def change
    add_column :news_items, :word_length, :integer
  end
end
