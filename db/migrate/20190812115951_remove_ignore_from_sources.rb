class RemoveIgnoreFromSources < ActiveRecord::Migration[5.2]
  def change
    remove_column :sources, :ignore, :boolean
  end
end
