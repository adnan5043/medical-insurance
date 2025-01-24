Rails.application.routes.draw do
  get 'welcome/index'
  resources :patients do
    member do
      patch :check_in
      patch :check_out
    end
  end
  resources :settings
  resources :admins
  resources :manage_receptions
  resources :branches, only: [:index, :new, :create, :edit, :update, :destroy]
  devise_for :users
  resources :denialcodelists do
    collection do
      post :import
    end
  end
  resources :doctorlists
  resources :transactions, only: [:index,:show] do
    collection do
        get 'download_report' 
      end
    post :fetch_transactions, on: :collection
  end
  root 'welcome#index'
end
