class AddTrendIndices < ActiveRecord::Migration[6.0]
  def change
    add_index :trends_words, :word, unique: true
    remove_column :trends_words, :parent_id
    add_index :trends_words, :ignore
  end
end
