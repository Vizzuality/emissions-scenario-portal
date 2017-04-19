Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :models, only: [:index, :show, :edit] do
    resources :scenarios, only: [:index], shallow: true
  end

  root to: 'models#index'
end
