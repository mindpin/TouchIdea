Rails.application.routes.draw do
  get '/:id' => 'votes#show_by_token', id: /[a-zA-Z0-9]{6}/, as: :token
  resources :messages
  resources :votes do
    resources :questions
    get :result, on: :member
  end
  devise_for :users, :controllers => { omniauth_callbacks: 'omniauth_callbacks' }
  root 'home#index'
end
