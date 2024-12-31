Rails.application.routes.draw do
  devise_for :users
  resources :denialcodelists
  resources :doctorlists
  resources :transactions, only: [] do
    collection do
        get 'download_report' 
      end
    post :fetch_transactions, on: :collection
  end
  root 'transactions#index'
end
