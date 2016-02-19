Baseapp::Application.routes.draw do
  get "about", to: "static_pages#about"

  namespace :admin do
    resources :sources
    resources :categories
    resources :mail_subscriptions, only: [:index, :show]
    resources :settings
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
    get :confirm, on: :member
  end

  get 'ni/:id' => 'news_items#show', as: :click_proxy

  get 'search' => 'news_items#index'
  get 'api/news_items/homepage' => 'news_items#homepage'

  get 'days' => redirect('/')
  get 'days/:year/:month/:day' => 'days#show', as: :raw_day
  get 'categories' => 'static_pages#categories'
  root to: "days#index"
  # root to: "static_pages#welcome"
end
