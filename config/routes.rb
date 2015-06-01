Baseapp::Application.routes.draw do

  get "about", to: "static_pages#about"
  get "sources", to: "static_pages#sources"

  namespace :admin do
    resources :sources
  end


  root to: "static_pages#welcome"
end
