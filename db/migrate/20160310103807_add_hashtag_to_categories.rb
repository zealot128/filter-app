class AddHashtagToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :hash_tag, :string
  end

  def data
    Category.find_each do |category|
      category.save
    end
  end
end
