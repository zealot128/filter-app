class WeeklySummaryJob < ApplicationJob
  queue_as :default

  def perform(week_start_str)
    week_start = Date.parse(week_start_str).beginning_of_week
    week_end = week_start.end_of_week

    # Check if summary already exists
    existing = WeeklySummary.find_by(week_start: week_start)
    return if existing.present?

    # Generate the summary
    generator = WeeklySummaryGenerator.new(
      start_date: week_start,
      end_date: week_end
    )

    result = generator.generate_summary

    # Store in database
    WeeklySummary.create!(
      week_start: week_start,
      summary: result[:summary],
      metadata: {
        generated_at: Time.current,
        news_count: result[:meta][:news_count],
        raw_response: result[:raw_response]
      }
    )

    Rails.logger.info "Generated weekly summary for week starting #{week_start}"
  rescue StandardError => e
    Rails.logger.error "Failed to generate weekly summary for #{week_start}: #{e.message}"
    raise e
  end
end
