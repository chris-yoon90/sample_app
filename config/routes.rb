SampleApp::Application.routes.draw do
  use_doorkeeper
 	resources :users do
 		member do
 			get :following, :followers
 		end
 	end
 	resources :sessions, only: [ :new, :create, :destroy]
 	resources :microposts, only: [:create, :destroy]
 	resources :relationships, only: [:create, :destroy]
	root 'static_pages#home'
	match '/help', to: 'static_pages#help', via: 'get'
	match '/about', to: 'static_pages#about', via: 'get'
	match '/contact', to: 'static_pages#contact', via: 'get'
	match '/signup', to: 'users#new', via: 'get'

	match '/signin', to: 'sessions#new', via: 'get'
	match '/signout', to: 'sessions#destroy', via: 'delete'

	namespace :api do
		namespace :v1 do
			resources :users, except: [:edit, :new], defaults: { format: :json }
			resources :sessions, only: [ :new, :create ]
		end
	end

end
