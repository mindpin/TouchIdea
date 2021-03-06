Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/zmkm', as: 'rails_admin'
  resources :notifications

  resource :notification_setting
  get '/:id' => 'votes#show_by_token', id: /[a-zA-Z0-9]{6}/, as: :token
  resources :votes do
    get :created_success, on: :member
    post :praise, on: :member
    get :hot, on: :collection
    get :done, on: :collection
    resources :vote_items
    get :lucky, on: :collection

    #resources :questions
    get :result, on: :member
    match :search, on: :collection, via: [:get, :post]

    # 三种不同类型的新建表单
    # 普通议题，购物分享，引用点评
    get :new_common,   on: :collection
    get :new_shopping, on: :collection
    get :new_quote,  on: :collection
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

  resources :infocards do
    get :parse_url, on: :collection
  end
end