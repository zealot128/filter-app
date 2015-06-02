Baseapp::Application.routes.draw do

  get "about", to: "static_pages#about"

  namespace :admin do
    resources :sources
  end

  get "sources" => redirect('/quellen')
  resources :sources, path: 'quellen', only: [:index, :show]

  get 'search' => 'news_items#index'
  get 'api/news_items/homepage' => 'news_items#homepage'

  root to: "static_pages#welcome"
end
