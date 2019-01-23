# == Schema Information
#
# Table name: ahoy_visits
#
#  id                   :bigint(8)        not null, primary key
#  visit_token          :string
#  visitor_token        :string
#  ip                   :string
#  user_agent           :text
#  referrer             :text
#  referring_domain     :string
#  landing_page         :text
#  whois_hostname       :string
#  recommended_username :string
#  used_search          :boolean
#  used_job_site        :boolean
#  browser              :string
#  os                   :string
#  device_type          :string
#  utm_source           :string
#  utm_medium           :string
#  utm_term             :string
#  utm_content          :string
#  utm_campaign         :string
#  started_at           :datetime
#  coworkr_code         :string
#  synced               :boolean          default(FALSE)
#

class Ahoy::Visit < ApplicationRecord
  self.table_name = "ahoy_visits"

  has_many :events, class_name: "Ahoy::Event", dependent: :destroy
end
