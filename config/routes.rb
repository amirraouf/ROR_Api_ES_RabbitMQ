Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :bugs, only: [:create,:show], constraints: { id: /\d+/ }
  get ':controller/:action'
end
