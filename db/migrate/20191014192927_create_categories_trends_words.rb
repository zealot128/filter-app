class CreateCategoriesTrendsWords < ActiveRecord::Migration[5.2]
  def change
    create_table :categories_trends_words, :id => false do |t|
      t.references :category
      t.references :trends_word
    end

    add_index :categories_trends_words, [:category_id, :trends_word_id],
      name: "categories_trends_words_index",
      unique: true
  end
end
