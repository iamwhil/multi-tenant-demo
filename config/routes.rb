Rails.application.routes.draw do
  get 'organizations/new'
  get 'organizations/create'
  get '/organizations/', to: 'organizations#index'

  get '/users/', to: 'users#index'
  get '/users/:id', to: 'users#show', as: 'user'
  get '/all_users/', to: 'users#all_users'

end
