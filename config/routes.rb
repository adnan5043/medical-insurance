Rails.application.routes.draw do
  root 'transactions#index'
resources :transactions do
  post :fetch_transactions, on: :collection
end
end
