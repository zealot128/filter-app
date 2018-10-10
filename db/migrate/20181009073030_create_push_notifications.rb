class CreatePushNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :push_notifications do |t|
      t.string :device_hash
      t.integer :response, default: 0
      t.text :error_response
      t.json :push_payload

      t.timestamps
      t.string :os
      t.string :app_version
    end
  end
end
