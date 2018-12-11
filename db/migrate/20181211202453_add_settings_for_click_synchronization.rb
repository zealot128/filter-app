class AddSettingsForClickSynchronization < ActiveRecord::Migration[5.2]
  def change
  end

  def data
    Setting.set('clicks_api', nil)
    Setting.set('clicks_api_token', nil)
  end
end
