# == Schema Information
#
# Table name: mail_subscription_histories
#
#  id                   :integer          not null, primary key
#  mail_subscription_id :integer
#  news_items_in_mail   :integer
#  opened_at            :datetime
#  open_token           :string
#  click_count          :integer          default(0)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_mail_subscription_histories_on_mail_subscription_id  (mail_subscription_id)
#
# Foreign Keys
#
#  fk_rails_...  (mail_subscription_id => mail_subscriptions.id)
#

class MailSubscription::History < ApplicationRecord
  belongs_to :mail_subscription
  scope :opened, -> { where.not(opened_at: nil) }

  def self.open_history(frame: 1.year.ago)
    MailSubscription::History.
      where('created_at > ?', frame.at_beginning_of_week).
      group('year', 'weekly').
      order('year desc, weekly desc').
      pluck(Arel.sql([
        "date_part('year', created_at::date) as year",
        "date_part('week', created_at::date) AS weekly",
        "count(*) as sent_count",
        "sum(case when opened_at is null then 0 else 1 end) as open_count"
      ].join(','))).
      map { |year, week, count, open|
      {
        year: year.to_i,
        week: week.to_i,
        sent: count,
        open: open,
        open_ratio: (open / count.to_f * 100).round(1)
      }
    }
  end

  before_save do
    self.open_token ||= SecureRandom.hex(32)
  end

  def click!
    update(opened_at: Time.zone.now) unless opened_at
    self.class.increment_counter :click_count, id
  end
end
