class MigrateLocaleToSettings < ActiveRecord::Migration[5.2]
  def change
  end

  def data
    Setting.set('impressum', I18n.t("impressum.#{Setting.key}"))
    Setting.set('mail_impressum', I18n.t("impressum.#{Setting.key}_mail_impressum"))
    Setting.set('datenschutz', I18n.t("datenschutz.#{Setting.key}"))
  end
end
