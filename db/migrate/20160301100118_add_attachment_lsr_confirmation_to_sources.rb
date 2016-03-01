class AddAttachmentLsrConfirmationToSources < ActiveRecord::Migration
  def self.up
    change_table :sources do |t|
      t.attachment :lsr_confirmation
    end
  end

  def self.down
    remove_attachment :sources, :lsr_confirmation
  end
end
