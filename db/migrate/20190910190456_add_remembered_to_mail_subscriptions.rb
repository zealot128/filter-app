class AddRememberedToMailSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :mail_subscriptions, :remembered, :datetime
  end
end
