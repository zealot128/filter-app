class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.string :type
      t.string :url
      t.string :name
      t.integer :value

      t.timestamps
    end
    add_index :sources, :type
  end
end
