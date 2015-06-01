Baseapp::Application.routes.draw do

  get "about", to: "static_pages#about"
  get "sources", to: "static_pages#sources"

  namespace :admin do
    resources :sources
  end

  get 'search' => 'news_items#index'
  get 'api/news_items/homepage' => 'news_items#homepage'

  root to: "static_pages#welcome"
end
