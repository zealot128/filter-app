class AddBoolsToSources < ActiveRecord::Migration
  def change
    change_table :sources do |t|
      t.boolean :lsr_active, default: false
      t.boolean :deactivated, default: false
      t.integer :default_category_id
    end
  end
end
