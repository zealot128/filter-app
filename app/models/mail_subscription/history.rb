# == Schema Information
#
# Table name: mail_subscription_histories
#
#  id                   :integer          not null, primary key
#  mail_subscription_id :integer
#  news_items_in_mail   :integer
#  opened_at            :datetime
#  open_token           :string
#  click_count          :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class MailSubscription::History < ApplicationRecord
  belongs_to :mail_subscription
  scope :opened, -> { where.not(opened_at: nil) }

  before_save do
    self.open_token ||= SecureRandom.hex(32)
  end

  def click!
    update(opened_at: Time.zone.now) unless opened_at
    self.class.increment_counter :click_count, id
  end
end
