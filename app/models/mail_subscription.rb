class MailSubscription < ActiveRecord::Base
  store_accessor :preferences, :categories
  store_accessor :preferences, :interval

  validates :interval, presence: true, inclusion: { in: ['weekly', 'monthly', 'biweekly'] }
  validates :categories, presence: true
  validates :email, presence: true
  validates_email_realness_of :email
  before_create do
    self.token = SecureRandom.hex(32)
  end

  def confirm!
    self.update_column :confirmed, true
  end

  def to_param
    self.token
  end

  def categories=(vals)
    super(vals.reject(&:blank?).map(&:to_i))
  end

  def self.cleanup
    where('confirmed = ?', false).where('created_at < ?', 1.day.ago).delete_all
  end
end
