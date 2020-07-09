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

  get '/js/trends' => 'trends#index'
  get '/trends/:slug' => 'trends#show', as: :trend

  get "/app", to: "app#index"

  namespace :admin do
    get 'trends' => 'trends/trends#index'
    get 'trends/months' => 'trends/words#months'
    get 'trends/weeks' => 'trends/words#weeks'
    namespace :trends do
      resources :trends
      resources :words do
        member do
          patch :ignore
          patch :merge
        end
      end
    end

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
    get 'twitter' => 'twitter#index'
    post 'twitter/follow' => 'twitter#follow'
  end
  get 'admin' => redirect('/admin/sources')

  if Setting.get('jobs_url').present? || Rails.env.test?
    get 'jobs' => 'jobs#index'
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
  get "mt/gif/:token", to: "mail_subscriptions#track_open", as: :mail_trackings_open

  get 'search' => 'news_items#index'
  get 'api/news_items/homepage' => 'news_items#homepage'

  get 'api/news_items' => 'api#news_items'
  get 'api/categories' => 'api#categories'

  get 'days' => 'days#index'
  get 'days/:year/:month/:day' => 'days#show', as: :raw_day

  resources :categories, path: "kategorien", only: [:index, :show]

  get '/auth/:provider/callback', to: 'admin/twitter#create'
  get '_bsc' => 'bsc#show'
  mount API => '/api/v1'
  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web, at: '/rails/sidekiq'
  end
  mount Ahoy::Engine => "/stellenanzeigen"
  root to: "static_pages#index"
end
