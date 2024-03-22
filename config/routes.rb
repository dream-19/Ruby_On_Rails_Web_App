Rails.application.routes.draw do
 
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root to: "events#index"
  
  devise_for :users, controllers: {
  registrations: 'users/registrations'
}

get 'my_events', to: 'events#my_events'
post '/bulk_destroy', to: 'events#bulk_destroy' 
get 'events/data', to: 'events#data', as: :events_data #before resources, otherwise it will be overridden!
resources :events


end
