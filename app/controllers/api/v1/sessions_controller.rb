module Api
	module V1
		class SessionsController < ApplicationController
			after_filter :set_csrf_header, only: [:new, :create] 
			
			def new
				@authorize_path = oauth_authorization_path(client_id: params[:client_id], 
					redirect_uri: params[:redirect_uri],
					response_type: params[:response_type])
			end

			def create
				user = User.find_by(email: params[:email].downcase)
				if user && user.authenticate(params[:password])
					remember_token = User.new_remember_token
					session[:remember_token] = remember_token
					user.update_attribute(:remember_token, User.digest(remember_token))
					redirect_to params[:authorize_path]
					#TODO: Must find out how to reset session to accomodate set_csrf_header method and resource_owner_authenticator block
				else
					flash.now[:error] = "Invalid email/Password combination"
					render 'new'
				end
			end

			private

			def set_csrf_header
				response.headers['X-CSRF-Token'] = form_authenticity_token
			end

		end
	end
end