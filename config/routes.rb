Rails.application.routes.draw do
  devise_for :users

  resource :profile, only: %i[edit update]
  resource :dashboard, only: %i[show]
  resources :templates, only: %i[show]
  resources :csv_uploads, only: %i[create]

  resources :models do
    resources :scenarios, only: %i[index show edit update destroy] do
      resources :time_series_values, only: %w[index]
    end

    resources :indicators do
      resources :time_series_values, only: %w[index]
    end
  end

  resources :indicators, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    resources :time_series_values, only: %w[index]
  end

  resources :teams, except: [:show] do
    resources :users, only: [:create, :destroy]
  end

  resources :locations, only: [:index, :new, :create, :edit, :update, :destroy]

  resources :categories, only: [:index, :new, :create, :edit, :update, :destroy] do
    resources :subcategories, only: [:create, :destroy]
  end

  root to: "models#index"

  namespace :api do
    namespace :v1 do
      resources :models, only: [:index, :show]
      resources :scenarios, only: [:index, :show]
      resources :indicators, only: [:index, :show]
      resources :time_series_values, only: [:index]
      resources :locations, only: [:index]
      resources :categories, only: [:index]
    end
  end
end
