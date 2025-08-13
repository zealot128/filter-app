class WeeklySummary < ApplicationRecord
  validates :week_start, presence: true, uniqueness: true

  def self.for_week(date)
    week_start = date.to_date.beginning_of_week
    find_by(week_start: week_start)
  end

  def self.generate_for_week(week_start = Date.current.beginning_of_week)
    WeeklySummaryJob.perform_later(week_start.to_s)
  end
end
