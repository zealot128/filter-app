class AddTwitterAccountToSources < ActiveRecord::Migration
  def change
    add_column :sources, :twitter_account, :string
  end
end
