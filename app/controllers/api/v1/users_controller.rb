module Api
	module V1
		class UsersController < ApplicationController

			#skip_before_filter :verify_authenticity_token
			after_filter :set_csrf_header, only: [:new, :create] # also include :new later
			respond_to :json

			def new
				# new action is called, csrf token set
				# send login form back on callback
			end

			def index
				@users = User.all(limit: 2) #supposed to use paginate
				respond_with @users
			end

			def show
				@user = User.find(params[:id])
				#@microposts = @user.microposts.all(limit: 5) #supposed to use paginate
				@microposts = Micropost.where("user_id = ?", @user.id).limit(5)
				respond_with user: @user, microposts: @microposts
			end

			def create
				respond_with User.create(user_params)
			end

			def destroy
				respond_with User.destroy(params[:id])
			end

			def update
				respond_with User.update_attribute(user_params)
			end

			private
				def user_params
  					params.require(:user).permit(:name, :email, :password, :password_confirmation)
  				end

  				def set_csrf_header
  					response.headers['X-CSRF-Token'] = form_authenticity_token
  				end

		end
	end
end