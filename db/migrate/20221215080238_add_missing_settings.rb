class AddMissingSettings < ActiveRecord::Migration[6.0]
  def change
    site_name = Setting.get('site_name')
    Setting.set('reminder_mail_1_days_body', Setting.get('reminder_mail_3_days_body'))
    Setting.set('reminder_mail_1_days_subject', "Dringend! Automatische Löschung Ihres #{site_name}-Abos steht kurz bevor!")
  end
end
