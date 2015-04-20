Rails.application.routes.draw do
  resources :emergencies
  resources :responders, param: :name
end
