class CreateLinkages < ActiveRecord::Migration
  def change
    create_table :linkages do |t|
      t.belongs_to :from, index: true
      t.belongs_to :to, index: true

      t.timestamps null: false
    end
  end
end
