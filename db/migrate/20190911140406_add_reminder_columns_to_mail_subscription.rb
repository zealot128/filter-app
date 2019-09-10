class AddReminderColumnsToMailSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :mail_subscriptions, :last_reminder_sent_at, :date
    add_column :mail_subscriptions, :number_of_reminder_sent, :integer, default: 0
  end
end
