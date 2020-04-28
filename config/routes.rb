Rails.application.routes.draw do
  get 'organizations/new'
  get 'organizations/create'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

get '/organizations/', to: 'organizations#index'

end
