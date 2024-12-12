Rails.application.routes.draw do
  resources :doctorlists
  resources :transactions do
    post :fetch_transactions, on: :collection
  end
  root 'transactions#index'
end
