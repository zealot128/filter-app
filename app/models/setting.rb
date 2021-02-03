# == Schema Information
#
# Table name: settings
#
#  id    :integer          not null, primary key
#  key   :string
#  value :text
#
# Indexes
#
#  index_settings_on_key  (key) UNIQUE
#

class Setting < ActiveRecord::Base
  GROUPS = {
    basis: [
      :database,
      :key,
      :tracking_code,
      :google_site_verification,
      :person,
      :person_email,
      :email,
      :site_name,
      :short_name,
      :host,
      :max_age,
    ],
    newsletter: [
      :promoted_feed_id,
      :mail_outro,
      :mail_intro,
      :mail_impressum,
      :from,
      :reconfirm_from,
      :inactive_months,
    ],
    seo: [
      :meta_description,
      :meta_keywords,
    ],
    texte: [
      :credits,
      :impressum,
      :datenschutz,
      :intro,
      :explanation
    ],
    trends: [
      :trend_min_sources_count,
    ],
    newsletter_erinnerung: [
      :inactive_months,
      :reminder_mail_14_days_subject,
      :reminder_mail_14_days_body,
      :reminder_mail_3_days_subject,
      :reminder_mail_3_days_body,
      :reminder_mail_1_day_subject,
      :reminder_mail_1_day_body,
      :reminder_unsubscribe_notice_subject,
      :reminder_unsubscribe_notice_body,
    ],
    twitter: [
      :twitter_account,
      :twitter_access_token,
      :twitter_access_secret,
    ],
    jobs: [
      :jobs_url
    ],
    clicks_sync: [
      :clicks_api,
      :clicks_api_token
    ]
  }.freeze

  serialize :value, JSON

  class << self
    def get(name, force: false)
      keys = [name]
      if I18n.locale == :en
        keys.prepend(name.to_s + '_en')
      end
      keys.each do |key|
        value = if force
                  get_value(key)
                else
                  to_hash[key.to_s] || get_value(key)
                end
        return value if !value.nil?
      end
      nil
    rescue ActiveRecord::StatementInvalid
      nil
    end

    def set(name, value)
      setting = where(key: name).first_or_initialize
      setting.value = value
      setting.save!
      clear
      value
    end

    def clear
      Rails.cache.delete("settings")
    end

    def to_hash
      Rails.cache.fetch("settings", expires_in: 1.hour) do
        to_h
      end
    rescue Errno::ENOENT
      to_h
    end

    def to_h
      pairs = all.map do |setting|
        [setting.key, setting.value]
      end
      Hash[pairs]
    end

    def get_value(name)
      Setting.select('value').find_by(key: name).try(:value)
    end

    def method_missing(m, *args, &block)
      (m != :find_by_key && get(m)) || super
    end

    def read_yaml
      configuration = begin
                        Rails.application.config_for(:application)
                      rescue RuntimeError
                        Rails.application.config_for('application.hrfilter')
                      end
      configuration.each do |k, v|
        set k, v
      end
    rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
    end
  end
end
