class AddFilterRulesToSources < ActiveRecord::Migration
  def change
    add_column :sources, :filter_rules, :text
  end
end
