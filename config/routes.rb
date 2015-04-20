Rails.application.routes.draw do
  resources :responders, param: :name
  # get '/responders/:name', to: 'responders#show'
end
