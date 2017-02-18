module BaseApi
  extend ActiveSupport::Concern

  included do
    cascade false

    rescue_from Grape::Exceptions::Validation do |e|
      Rack::Response.new({
        'status' => e.status,
        'message' => "Missing parameter",
        'attribute' => e.param
      }.to_json, e.status)
    end
    rescue_from ArgumentError, NotImplementedError
    rescue_from :all do |e|
      if Rails.env.test?
        raise e
      end
      trace = e.backtrace.grep(File.basename(Rails.root))
      Rails.logger.error "#{e.message}\n\n#{trace.join("\n")}"
      if Rails.env.production?
        Airbrake.notify(e) if defined?(Airbrake)
        ExceptionNotification.notify_exception(e) if defined?(ExceptionNotification)
      end
      Rack::Response.new({ message: e.message, backtrace: trace }.to_json, 500, { 'Content-type' => 'application/json' }).finish
    end
    default_format :json
    logger Rails.logger
  end
end

