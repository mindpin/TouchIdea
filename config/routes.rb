Rails.application.routes.draw do
  resources :messages
  resources :votes do
    resources :questions
    get :result, on: :member
  end
  devise_for :users, :controllers => { omniauth_callbacks: 'omniauth_callbacks' }
  root 'home#index'
end
