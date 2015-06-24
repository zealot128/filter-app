class AddMultiplicatorToSources < ActiveRecord::Migration
  def change
    add_column :sources, :multiplicator, :float, default: 1
  end
end
