class AddDeletedAtToMailSubscriptions < ActiveRecord::Migration
  def change
    add_column :mail_subscriptions, :deleted_at, :datetime
  end
end
