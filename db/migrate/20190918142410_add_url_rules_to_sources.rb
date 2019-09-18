class AddUrlRulesToSources < ActiveRecord::Migration[6.0]
  def change
    add_column :sources, :url_rules, :text
  end
end
