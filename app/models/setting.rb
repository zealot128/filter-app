# == Schema Information
#
# Table name: settings
#
#  id    :integer          not null, primary key
#  key   :string
#  value :text
#

class Setting < ActiveRecord::Base
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
      begin
        pairs = all.map do |setting|
          [setting.key, setting.value]
        end
        Hash[pairs]
      end
    end

    def get_value(name)
      Setting.select('value').find_by_key(name).try(:value)
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
