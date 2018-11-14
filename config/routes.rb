Baseapp::Application.routes.draw do
  resources :sources
  get "impressum", to: "static_pages#impressum"
  get "datenschutz", to: "static_pages#datenschutz"
  get "faq", to: "static_pages#faq"

  namespace :admin do
    resources :sources do
      member do
        post :refresh
      end
    end
    resources :categories
    resources :mail_subscriptions, only: [:index, :show, :destroy] do
      post :confirm, on: :member
    end
    resources :settings
    get 'twitter' => 'twitter#index'
    post 'twitter/follow' => 'twitter#follow'
  end
  get 'admin' => redirect('/admin/sources')

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

  get 'days' => redirect('/')
  get 'days/:year/:month/:day' => 'days#show', as: :raw_day
  get 'categories' => 'static_pages#categories'

  get '/auth/:provider/callback', to: 'admin/twitter#create'
  get '_bsc' => 'bsc#show'
  mount API => '/api/v1'
  root to: "days#index"
end
