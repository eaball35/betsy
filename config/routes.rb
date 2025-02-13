Rails.application.routes.draw do
  root "homepages#index"
  
  resources :products do
    resources :order_items, only: [:create]
  end
  
  get "/auth/github", as: "github_login"
  get "/auth/:provider/callback", to: "users#create", as: "auth_callback"
  delete "/logout", to: "users#destroy", as: "logout"
  
  get "/users/current", to: "users#current", as: "current_user"
  get "/users/current/edit", to: "users#edit", as: "edit_user"
  
  resources :users, only: [:show, :update]
  
  get "/orders/cart", to: "orders#cart", as: "cart"
  get "/orders/checkout", to: "orders#checkout", as: "checkout"
  get "/orders/confirmation", to: "orders#confirmation", as: "confirmation"
  resources :orders, only: [:show] 
  patch "/orders/:id", to: "orders#update_paid"
  patch "/orders/:id/cancel", to: "orders#cancel_order", as: "cancel_order"
  patch "/orders/:id/complete", to: "orders#complete_order", as: "complete_order"

  resources :categories do
    resources :products, only: [:index]
  end
  
  resources :order_items, only: [:update, :destroy]
  
  resources :reviews, only: [:create, :destroy]
end
