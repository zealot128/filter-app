class CreateWords < ActiveRecord::Migration[5.2]
  def change
    create_table :trends_words do |t|
      t.string :word
      t.integer :parent_id

      t.boolean :ignore
    end
  end
end
