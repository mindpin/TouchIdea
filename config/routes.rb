Rails.application.routes.draw do
  resources :votes do
    get :result, on: :member
  end
  devise_for :users, :controllers => { omniauth_callbacks: 'omniauth_callbacks' }
  root 'home#index'
end
