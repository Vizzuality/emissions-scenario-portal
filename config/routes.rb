Rails.application.routes.draw do
  devise_for :users
  get 'profiles/edit' => 'profiles#edit', as: 'edit_profile'
  put 'profiles' => 'profiles#update', as: 'profile'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :models, only: [:index, :show, :new, :create, :edit, :update] do
    post :upload_meta_data, on: :collection
    resources :scenarios, only: [:index, :show, :edit, :update, :destroy] do
      post :upload_meta_data, on: :collection
      post :upload_time_series, on: :collection, to: 'time_series_values#upload', as: :upload_time_series
    end
    resources :indicators, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
      post :upload_meta_data, on: :collection#, as: :upload_indicators_meta_data
    end
  end

  resources :teams, except: [:show] do
    resources :users, only: [:create, :destroy], controller: 'team_users'
  end

  resources :locations, only: [:index, :new, :create, :edit, :update, :destroy]

  # Rails routes are matched in the order they are specified
  root to: "admin#home",
    constraints: lambda { |request| request.env['warden'].user.try(:admin?) },
    as: :admin_root
  root to: "models#index"
end
