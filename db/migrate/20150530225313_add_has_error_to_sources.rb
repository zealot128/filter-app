class AddHasErrorToSources < ActiveRecord::Migration
  def change
    add_column :sources, :error, :boolean
  end
end
