Rails.application.routes.draw do
  devise_for :users
  get 'profiles/edit' => 'profiles#edit', as: 'edit_profile'
  put 'profiles' => 'profiles#update', as: 'profile'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :models, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    post :upload_meta_data, on: :collection
    get :upload_template, on: :collection
    resources :scenarios, only: [:index, :show, :edit, :update, :destroy] do
      post :upload_meta_data, on: :collection
      post :upload_time_series, on: :collection, to: 'time_series_values#upload', as: :upload_time_series
      get :upload_time_series_template, on: :collection, to: 'time_series_values#upload_template', as: :upload_time_series_template
      get :download_time_series, on: :member
      get :upload_template, on: :collection
    end
    resources :indicators do
      post :upload_meta_data, on: :collection
      get :download_time_series, on: :member
      get :upload_template, on: :collection
    end
  end

  resources :indicators do
      post :upload_meta_data, on: :collection
      get :download_time_series, on: :member
      get :upload_template, on: :collection
  end

  resources :teams, except: [:show] do
    resources :users, only: [:create, :destroy], controller: 'team_users'
  end

  namespace :admin do
    resources :indicators, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
      post :upload_meta_data, on: :collection
      get :download_time_series, on: :member
      get :upload_template, on: :collection
      put :promote, on: :member
    end

    resources :teams, except: [:show] do
      resources :users, only: [:create, :destroy], controller: 'team_users'
    end

    resources :locations, only: [:index, :new, :create, :edit, :update, :destroy]

    resources :categories, only: [:index, :new, :create, :edit, :update, :destroy] do
      resources :subcategories, only: [:create, :destroy]
    end

    root to: "home#index"
  end

  root to: "models#index"

  # Namespaced API routes
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
