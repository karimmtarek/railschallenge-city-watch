Rails.application.routes.draw do
  resources :emergencies, param: :code
  resources :responders, param: :name
end
