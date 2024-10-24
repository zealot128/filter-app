# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   allow do
#     origins "example.com"
#
#     resource "*",
#       headers: :any,
#       methods: [:get, :post, :put, :patch, :delete, :options, :head]
#   end
# end

Rails.application.configure do
  config.middleware.insert_before 0, Rack::Cors, debug: true, logger: ::Logger.new(STDOUT) do
    allow do
      if Rails.env.development?
        origins "pludoni.#{ENV['LOGNAME']}.pludoni.com"
      else
        origins 'www.pludoni.de'
      end
      resource '/api/v1/categories.json', headers: :any, methods: :get
      resource '/api/v1/news_items.json', headers: :any, methods: :get
    end
  end
end
