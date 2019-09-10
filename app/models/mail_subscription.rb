# == Schema Information
#
# Table name: mail_subscriptions
#
#  id              :integer          not null, primary key
#  email           :text
#  preferences     :json
#  token           :string
#  last_send_date  :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  limit           :integer
#  gender          :integer
#  first_name      :string
#  last_name       :string
#  academic_title  :string
#  company         :string
#  position        :string
#  extended_member :boolean          default(FALSE)
#  deleted_at      :datetime
#  status          :integer          default("unconfirmed")
#  remembered_at   :datetime
#
# Indexes
#
#  index_mail_subscriptions_on_token  (token) UNIQUE
#

class MailSubscription < ApplicationRecord
  has_many :histories, class_name: "MailSubscription::History", dependent: :destroy
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
  scope :deleted, -> { where 'deleted_at is not null' }
  scope :inactive_for, -> { where('last_send_date > ?', (Setting.inactive_months.to_i).months) }

  validates :privacy, acceptance: true

  has_many :impressions, foreign_key: 'user_id', dependent: :destroy

  enum status: [:unconfirmed, :confirmed, :unsubscribed]

  def confirm!
    update_column :status, MailSubscription.statuses[:confirmed]
  end

  def due?
    return true if last_send_date.nil?
    (last_send_date + interval_from).to_date <= Time.zone.today
  end

  def interval_from
    {
      'weekly' => 1.week,
      'biweekly' => 2.weeks,
      'monthly' => 1.month
    }[interval]
  end

  def salutation
    if gender.present? and last_name?
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
    self.deleted_at = Time.zone.now
    self.categories = []
    self.token = nil
    save validate: false
  end

  def categories=(vals)
    super(vals.reject(&:blank?).map(&:to_i))
  end
end
