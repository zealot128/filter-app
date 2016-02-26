class AddStatusToMailSubscriptions < ActiveRecord::Migration
  def change
    add_column :mail_subscriptions, :status, :integer, default: 0
    execute 'update mail_subscriptions set status = 1 where confirmed'
    remove_column :mail_subscriptions, :confirmed
  end
end
