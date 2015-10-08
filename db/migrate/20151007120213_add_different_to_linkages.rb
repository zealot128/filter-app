class AddDifferentToLinkages < ActiveRecord::Migration
  def change
    add_column :linkages, :different, :boolean, default: false
  end
end
