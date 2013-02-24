class AddAttachmentLogoToSources < ActiveRecord::Migration
  def self.up
    change_table :sources do |t|
      t.attachment :logo
    end
  end

  def self.down
    drop_attached_file :sources, :logo
  end
end
