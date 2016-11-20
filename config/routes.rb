Rails.application.routes.draw do
  root 'home#index'
  post 'message' => 'home#message', as: 'message'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
