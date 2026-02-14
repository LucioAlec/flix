Rails.application.routes.draw do
  root "movies#index"
  resources :movies do
    resources :reviews
    resources :favorites, only: [ :create, :destroy ]
  end
=begin
  get "movies" => "movies#index"
  get "movies/new" => "movies#new"
  get "movies/:id" => "movies#show", as: "movie"
  get "movies/:id/edit"=> "movies#edit", as: "edit_movie"
  patch "movies/:id" => "movies#update"
=end
resource :session, only: [ :new, :create, :destroy ]
resources :users
get "signin" =>"sessions#new"
get "signup" =>"users#new"
end
