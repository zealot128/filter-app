class CreateMailSubscriptions < ActiveRecord::Migration
  def change
    create_table :mail_subscriptions do |t|
      t.text :email
      t.json :preferences
      t.string :token
      t.boolean :confirmed
      t.datetime :last_send_date

      t.timestamps null: false
    end
    add_index :mail_subscriptions, :token, unique: true
  end
end
