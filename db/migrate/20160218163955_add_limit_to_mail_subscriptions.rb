class AddLimitToMailSubscriptions < ActiveRecord::Migration
  def change
    add_column :mail_subscriptions, :limit, :integer
    execute 'update mail_subscriptions set "limit" = 50'
  end
end
