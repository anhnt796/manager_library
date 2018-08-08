Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi|ja/ do
    root "static_pages#home"
  end

  get "/help", to: "static_pages#help"
  get "/about", to: "static_pages#about"
  get "/contact", to: "static_pages#contact"

  get "auth/:provider/callback", to: "omniauth_callbacks#create"
  get "auth/failure", to: "omniauth_callbacks#failure"

  get "/signup", to: "users#new"
  post "/signup", to: "users#create"

  get "/register", to: "users#register_card"
  patch "/register", to: "users#require_card"

  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  resources :users
  resources :books do
    resources :comments
    resources :copies, only: %i(index new create update destroy)
  end
  #resources :copies, only: %i(index new create update destroy)
  resources :card_activations, only: %i(edit)
  resources :password_resets, only: %i(new create edit update)
  resources :registered_copies, only: %i(index new create update destroy)
  resources :book_confirmations, only: %i(index update destroy)
  resources :comment_confirmations, only: %i(index update destroy)
  resources :notifications, only: %i(index create destroy)
end
