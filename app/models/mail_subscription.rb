# == Schema Information
#
# Table name: mail_subscriptions
#
#  id                      :integer          not null, primary key
#  email                   :text
#  preferences             :json
#  token                   :string
#  last_send_date          :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  limit                   :integer
#  gender                  :integer
#  first_name              :string
#  last_name               :string
#  academic_title          :string
#  company                 :string
#  position                :string
#  deleted_at              :datetime
#  status                  :integer          default("unconfirmed")
#  remembered_at           :datetime
#  last_reminder_sent_at   :date
#  number_of_reminder_sent :integer          default(0)
#
# Indexes
#
#  index_mail_subscriptions_on_token  (token) UNIQUE
#

class MailSubscription < ApplicationRecord
  has_many :histories, class_name: "MailSubscription::History", dependent: :destroy
  store_accessor :preferences, :categories
  store_accessor :preferences, :interval
  enum :gender, { female: 0, male: 1 }

  validates :interval, presence: true, inclusion: { in: %w(weekly monthly biweekly) }
  validates :categories, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :limit, presence: true
  validates :first_name, :last_name, format: { with: /\A[\p{L} \.-]+\z/i }
  validates :first_name, :last_name, format: { without: /https|http/i }

  before_create do
    self.token = SecureRandom.hex(32)
  end
  scope :deleted, -> { where.not(deleted_at: nil) }
  scope :inactive_for, -> { where('last_send_date > ?', Setting.inactive_months.to_i.months) }
  scope :undeleted, -> { where deleted_at: nil }

  validates :privacy, acceptance: true

  enum :status, { unconfirmed: 0, confirmed: 1, unsubscribed: 2 }

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
      [male? ? "Sehr geehrter Herr" : "Sehr geehrte Frau", academic_title, last_name].compact_blank.join(' ')
    else
      'Hallo'
    end
  end

  def full_email
    if gender? and last_name?
      address = Mail::Address.new email
      address.display_name = [first_name, last_name].compact_blank.join(' ')
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
    super(vals.compact_blank.map(&:to_i))
  end
end
