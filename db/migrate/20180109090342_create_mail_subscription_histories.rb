class CreateMailSubscriptionHistories < ActiveRecord::Migration
  def change
    create_table :mail_subscription_histories do |t|
      t.belongs_to :mail_subscription, index: true, foreign_key: true
      t.integer :news_items_in_mail
      t.datetime :opened_at
      t.string :open_token
      t.integer :click_count, default: 0

      t.timestamps null: false
    end
  end
end
