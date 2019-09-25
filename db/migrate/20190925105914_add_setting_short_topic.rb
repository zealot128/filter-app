class AddSettingShortTopic < ActiveRecord::Migration[6.0]
  def change
  end

  def data
    Setting.set('topic_short', 'HR')
  end
end
