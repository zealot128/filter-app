class AddSettingPersonEmail < ActiveRecord::Migration
  def change
  end

  def data
    Setting.set('person_email', 'andreas.manietta@pludoni.de')
  end
end
