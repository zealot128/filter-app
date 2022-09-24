class MigrateMailSubscriptionTextsToMjml < ActiveRecord::Migration[6.0]
  def change
    Setting.where(key: %w[reminder_unsubscribe_notice_body reminder_mail_3_days_body reminder_mail_14_days_body]).each do |setting|
      doc = Nokogiri::HTML.fragment(setting.value)
      doc.search('p').each { |i| i.name = 'mj-text' }
      doc.search('a').each { |i| i.name = 'mj-button' }
      doc.search('table.button').each { |i| i.replace(i.at('td').inner_html) }
      doc.search('mj-text mj-button').each { |i| i.replace(i.inner_html) }

      setting.update(value: doc.to_s.gsub("%7B", "{").gsub("%7D", "}"))
    end
  end
end
