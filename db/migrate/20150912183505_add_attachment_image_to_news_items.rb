class AddAttachmentImageToNewsItems < ActiveRecord::Migration
  def self.up
    change_table :news_items do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :news_items, :image
  end
end
