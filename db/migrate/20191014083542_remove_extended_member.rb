class RemoveExtendedMember < ActiveRecord::Migration[6.0]
  def change
    remove_column :mail_subscriptions, :extended_member
  end
end
