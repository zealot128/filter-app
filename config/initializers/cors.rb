Rails.application.configure do
  config.middleware.insert_before 0, Rack::Cors, :debug => true, :logger => ::Logger.new(STDOUT) do
    allow do
      if Rails.env.development?
        origins "pludoni.#{ENV['USER']}.pludoni.com"
      else
        origins 'www.pludoni.de'
      end
      resource '/api/v1/categories.json', headers: :any, methods: :any, credentials: true
      resource '/api/v1/news_items.json?category_id=1&limit=10', headers: :any, methods: :any, credentials: true
    end
  end
end
