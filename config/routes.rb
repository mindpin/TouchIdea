Rails.application.routes.draw do
  resources :notifications

  resource :notification_setting
  get '/:id' => 'votes#show_by_token', id: /[a-zA-Z0-9]{6}/, as: :token
  resources :votes do
    get :created_success
    post :praise, on: :member
    get :hot, on: :collection
    get :done, on: :collection
    resources :vote_items
    match :lucky, on: :collection, via: [:get, :post]

    #resources :questions
    get :result, on: :member
    match :search, on: :collection, via: [:get, :post]
  end
  devise_for :users, :controllers => { omniauth_callbacks: 'omniauth_callbacks' }
  root 'home#index'

  get '/account' => 'account#index'
  get '/account/created_votes' => 'account#created_votes'
  get '/account/joined_votes' => 'account#joined_votes'
  get '/account/notification_setting' => 'account#notification_setting'
  get '/account/feedback'     => 'account#feedback'
  get '/account/about'     => 'account#about'
  get '/account/info'      => 'account#info'
  resources :feedbacks
  resources :infocards
end
