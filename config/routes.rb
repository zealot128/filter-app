Baseapp::Application.routes.draw do

  devise_for :users
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
  get "about", to: "static_pages#about"
  get "sources", to: "static_pages#sources"

  root to: "static_pages#welcome"
end
