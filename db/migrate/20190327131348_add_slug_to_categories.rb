class AddSlugToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :slug, :string
    execute 'update categories set slug = name'
    add_index :categories, :slug, unique: true
  end
end
