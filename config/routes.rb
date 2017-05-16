Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :models, only: [:index, :show, :edit, :update] do
    resources :scenarios, only: [:index], shallow: true
  end
  resources :indicators, only: [:index, :show, :new, :create, :edit, :update, :destroy]

  root to: 'models#index'
end
