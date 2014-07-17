module Api
	module V1
		class UsersController < ApplicationController

			skip_before_filter :verify_authenticity_token
			respond_to :json

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

		end
	end
end