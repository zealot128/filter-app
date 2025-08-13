class Resources::WeeklySummaries < Grape::API
  include BaseAPI

  helpers do
    def authenticate!
      if params[:api_key] != Rails.application.credentials.secret_api_key
        error!({ message: 'missing/wrong api key' }, 403)
      end
    end
  end

  before do
    authenticate!
  end

  namespace :weekly_summary do
    desc 'Generate weekly HR news summary'
    params do
      optional :from_date, type: Date, desc: 'Start date for the summary (defaults to 1 week ago)'
      optional :to_date, type: Date, desc: 'End date for the summary (defaults to today)'
    end
    get '/' do
      start_date = params[:from_date] || 1.week.ago.to_date
      end_date = params[:to_date] || Date.current

      # Validate date range
      if end_date < start_date
        error!({ message: 'to_date must be after from_date' }, 422)
      end

      if (end_date - start_date).to_i > 30
        error!({ message: 'Date range cannot exceed 30 days' }, 422)
      end

      generator = WeeklySummaryGenerator.new(
        start_date: start_date,
        end_date: end_date
      )

      result = generator.generate_summary

      # Return only the summary JSON, not the meta or raw_response
      result[:summary]
    end
  end
end
