class AddSettingFeedId < ActiveRecord::Migration
  def change
  end

  def data
    Setting.set('promoted_feed_id', 0)
  end
end
