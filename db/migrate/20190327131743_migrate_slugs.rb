class MigrateSlugs < ActiveRecord::Migration[5.2]
  def change
    Category.find_each do |c|
      c.generate_slug
      c.save!
    end
  end
end
