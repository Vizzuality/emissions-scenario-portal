Rails.application.routes.draw do
  devise_for :users

  resource :profile, only: %i[edit update]
  resource :dashboard, only: %i[show]
  resources :templates, only: %i[show]
  resources :csv_uploads, only: %i[create]

  resources :models do
    collection do
      post :metadata
    end

    resources :scenarios, only: %i[index show edit update destroy] do
      collection do
        post :upload_meta_data
        post :upload_time_series, to: 'time_series_values#upload', as: :upload_time_series
      end
      member do
        get :download_time_series
      end
    end

    resources :indicators do
      collection do
        post :upload_meta_data
      end
      member do
        get :download_time_series
      end
    end
  end

  resources :indicators, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    collection do
      post :upload_meta_data
    end
    member do
      get :download_time_series
    end
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
