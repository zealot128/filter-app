class MailSubscription < ActiveRecord::Base
  store_accessor :preferences, :categories
  store_accessor :preferences, :interval

  validates :interval, presence: true, inclusion: { in: %w(weekly monthly biweekly) }
  validates :categories, presence: true
  validates :email, presence: true
  validates :limit, presence: true
  validates_email_realness_of :email
  before_create do
    self.token = SecureRandom.hex(32)
  end
  scope :confirmed, -> { where confirmed: true }

  def confirm!
    update_column :confirmed, true
  end

  def due?
    return true if last_send_date.nil?
    (last_send_date + interval_from).to_date <= Date.today
  end

  def interval_from
    {
      'weekly' => 1.week,
      'biweekly' => 2.weeks,
      'monthly' => 1.month
    }[interval]
  end

  def to_param
    token
  end

  def categories=(vals)
    super(vals.reject(&:blank?).map(&:to_i))
  end

  def self.cleanup
    where('confirmed = ?', false).where('created_at < ?', 1.day.ago).delete_all
  end
end
