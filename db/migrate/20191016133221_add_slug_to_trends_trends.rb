class AddSlugToTrendsTrends < ActiveRecord::Migration[6.0]
  def change
    add_column :trends_trends, :slug, :string
    add_index :trends_trends, :slug, unique: true
  end
end
