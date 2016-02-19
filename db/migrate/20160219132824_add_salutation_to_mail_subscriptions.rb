class AddSalutationToMailSubscriptions < ActiveRecord::Migration
  def change
    change_table :mail_subscriptions do |t|
      t.integer :gender
      t.string :first_name
      t.string :last_name
      t.string :academic_title
      t.string :company
      t.string :position
      t.boolean :extended_member, default: false
    end
  end
end
