Baseapp::Application.routes.draw do

  devise_for :users
  get "about", to: "static_pages#about"
  get "sources", to: "static_pages#sources"

  root to: "static_pages#welcome"
end
