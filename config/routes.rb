Baseapp::Application.routes.draw do

  get "about", to: "static_pages#about"

  namespace :admin do
    resources :sources
    resources :categories
    resources :mail_subscriptions, only: [:index, :show]
  end

  get "sources" => redirect('/quellen')
  resources :sources, path: 'quellen', only: [:index, :show]

  resources :submit_source, path: 'submit_source', only: [:new, :create]

  resources :mail_subscriptions, path: 'newsletter' do
    get :confirm, on: :member
  end

  get 'ni/:id' => 'news_items#show', as: :click_proxy

  get 'search' => 'news_items#index'
  get 'api/news_items/homepage' => 'news_items#homepage'

  root to: "static_pages#welcome"
end
