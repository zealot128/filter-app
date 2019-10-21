class AddIndexWordTypeOnWords < ActiveRecord::Migration[6.0]
  def change
    add_index :trends_words, :word_type
  end
end
