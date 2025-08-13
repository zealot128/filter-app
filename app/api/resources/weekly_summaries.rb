class Resources::WeeklySummaries < Grape::API
  include BaseAPI

  helpers do
    def authenticate!
      if params[:api_key] != Rails.application.credentials.secret_api_key && Rails.application.credentials.secret_api_key
        error!({ message: 'missing/wrong api key' }, 403)
      end
    end
  end

  before do
    authenticate!
  end

  namespace :weekly_summary do
    desc 'Get pre-generated weekly HR news summary'
    params do
      optional :week_date, type: Date, desc: 'Date within the desired week (defaults to current week)'
    end
    get '/' do
      target_date = params[:week_date] || Date.current

      # Find the summary for the week containing this date
      summary = WeeklySummary.for_week(target_date)

      if summary.present?
        summary.summary
      end
    end
  end
end
