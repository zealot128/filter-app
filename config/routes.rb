Baseapp::Application.routes.draw do

  get "about", to: "static_pages#about"
  get "sources", to: "static_pages#sources"

  root to: "static_pages#welcome"
end
