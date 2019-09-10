class ChangeColumnName < ActiveRecord::Migration[5.2]
  def change
    rename_column :mail_subscriptions, :remembered, :remembered_at
  end
end
