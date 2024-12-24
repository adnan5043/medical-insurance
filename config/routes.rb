Rails.application.routes.draw do
  devise_for :users
  resources :denialcodelists
  resources :doctorlists
  resources :transactions do
    post :fetch_transactions, on: :collection
  end
  root 'transactions#index'
end
