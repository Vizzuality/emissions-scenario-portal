Rails.application.routes.draw do
  devise_for :users

  resource :profile, only: %i[edit update]
  resource :dashboard, only: %i[show]
  resources :templates, only: %i[show]
  resources :csv_uploads, only: %i[create]
  resources :locations, only: %i[index new create edit update destroy]
  resources :categories, only: %i[index new create edit update destroy] do
    resources :subcategories, only: %i[create destroy]
  end
  resources :teams, only: %i[index new create edit update destroy] do
    resources :users, only: %i[create destroy]
  end
  resources :indicators do
    resources :time_series_values, only: %i[index]
  end
  resources :models do
    resources :scenarios, only: %i[index show edit update destroy] do
      resources :time_series_values, only: %i[index]
    end

    resources :indicators, only: %i[index show] do
      resources :time_series_values, only: %i[index]
      resource :note, only: %i[edit update]
    end
  end

  namespace :api do
    namespace :v1 do
      resources :models, only: %i[index show]
      resources :scenarios, only: %i[index show]
      resources :indicators, only: %i[index show]
      resources :time_series_values, only: %i[index]
      resources :locations, only: %i[index] do
        resources :time_series_values, controller: :location_time_series_values, only: %i[index]
      end
      resources :categories, only: %i[index]
      resources :subcategories, only: %i[index]
    end
  end

  root to: "models#index"
end
