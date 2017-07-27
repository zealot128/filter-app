class AddTrendCategory < ActiveRecord::Migration[6.0]
  def change
    add_column :trends_usages, :date, :date
    add_column :trends_words, :word_type, :integer, default: 0
  end
end
