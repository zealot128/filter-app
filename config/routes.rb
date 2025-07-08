Rails.application.routes.draw do
  devise_for :users
  resources :sources
  get "impressum", to: "static_pages#impressum"
  get "datenschutz", to: "static_pages#datenschutz"
  get "faq", to: "static_pages#faq"

  get "rss", to: 'rss#index'
  get "rss/daily-top-10", to: 'rss#daily_top_10', as: :daily_top_10_rss
  get "rss/daily-top-50", to: 'rss#daily_top_50', as: :daily_top_50_rss
  get "rss/weekly-top-50", to: 'rss#weekly_top_50', as: :weekly_top_50_rss
  get "rss/newest", to: 'rss#newest', as: :newest_rss


  get "/app", to: "app#index"

  namespace :admin do

    get '/' => 'sources#dashboard', as: :dashboard
    resources :sources do
      member do
        post :refresh
        patch :download_image
        get :score_chart
      end
      collection do
        post :autofetch
      end
    end
    resources :categories
    resources :mail_subscriptions, only: [:index, :show, :destroy] do
      post :confirm, on: :member
    end
    resources :settings
    resources :users
  end
  get 'admin' => redirect('/admin/sources')

  if Setting.get('jobs_url').present? || Rails.env.test?
    get 'jobs' => 'jobs#index'
    get 'events' => 'jobs#events'
  end

  get "sources" => redirect('/quellen')
  resources :sources, path: 'quellen', only: [:index, :show] do
    member do
      get :search
    end
  end

  get '/quelle_einreichen' => 'submit_source#new', as: :new_submit_source
  post '/quelle_einreichen' => 'submit_source#create'

  resources :mail_subscriptions, path: 'newsletter' do
    member do
      get :confirm
      get :reconfirm
      get :created
    end
    collection do
      get :embed
    end
  end

  get 'ni/:id' => 'news_items#show', as: :click_proxy
  get 'share/:id/:channel' => 'news_items#share', as: :share_news_item
  get "mt/gif/:token", to: "mail_subscriptions#track_open", as: :mail_trackings_open

  get 'search' => 'news_items#index'
  get 'api/news_items/homepage' => 'news_items#homepage'

  get 'api/news_items' => 'api#news_items'
  get 'api/categories' => 'api#categories'

  get 'days' => 'days#index'
  get 'days/:year/:month/:day' => 'days#show', as: :raw_day

  resources :categories, path: "kategorien", only: [:index, :show]

  get '_bsc' => 'bsc#show'
  mount API => '/api/v1'
  mount Ahoy::Engine => "/stellenanzeigen"
  if Rails.env.production?
    mount MissionControl::Jobs::Engine, at: "/rails/jobs"
  end
  get 'up' => 'up#index'
  root to: "days#index"
end
