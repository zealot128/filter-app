class MailSubscription < ActiveRecord::Base
  store_accessor :preferences, :categories
  store_accessor :preferences, :interval
  enum gender: [:female, :male]

  validates :interval, presence: true, inclusion: { in: %w(weekly monthly biweekly) }
  validates :categories, presence: true
  validates :email, presence: true
  validates :limit, presence: true
  validates_email_realness_of :email
  before_create do
    self.token = SecureRandom.hex(32)
  end
  scope :confirmed, -> { where status: 1 }
  scope :deleted, -> { where 'deleted_at is not null' }

  has_many :impressions, foreign_key: 'user_id'

  enum status: [:unconfirmed, :confirmed, :unsubscribed]

  def confirm!
    update_column :status, MailSubscription.statuses[:confirmed]
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

  def salutation
    if gender? and last_name?
      [male? ? "Sehr geehrter Herr" : "Sehr geehrte Frau", academic_title, last_name].reject(&:blank?).join(' ')
    else
      'Hallo'
    end
  end

  def full_email
    if gender? and last_name?
      address = Mail::Address.new email
      address.display_name = [first_name, last_name].reject(&:blank?).join(' ')
      address.format
    else
      email
    end
  end

  def to_param
    token
  end

  def destroy
    self.email = "deleted_#{id}_#{email}"
    self.gender = nil
    self.extended_member = false
    self.status = 'unsubscribed'
    self.first_name = nil
    self.last_name = nil
    self.company = nil
    self.academic_title = nil
    self.position = nil
    self.deleted_at = Time.now
    self.categories = []
    self.token = nil
    self.save validate: false
  end

  def categories=(vals)
    super(vals.reject(&:blank?).map(&:to_i))
  end

  # def self.cleanup
  #   where('confirmed = ? and deleted_at is null', false).where('created_at < ?', 14.day.ago).delete_all
  # end
end
