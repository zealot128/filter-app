class AddIgnoreToSources < ActiveRecord::Migration[5.2]
  def change
    add_column :sources, :ignore, :boolean, :default => false
  end
end
