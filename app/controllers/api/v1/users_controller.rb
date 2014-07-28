module Api
	module V1
		class UsersController < ApplicationController

			doorkeeper_for :all, except: [:show, :create]
			#skip_before_filter :verify_authenticity_token
			respond_to :json


			def index
				@users = User.paginate(page: params[:page], per_page: 15)
				respond_with @users
			end

			def show
				@user = User.find(params[:id])
				@microposts = @user.microposts.paginate(page: params[:page], per_page: 15)
				#@microposts = Micropost.where("user_id = ?", @user.id).limit(5)
				respond_with user: @user, microposts: @microposts
			end

			def create
				respond_with User.create(user_params)
			end

			def destroy
				respond_with User.destroy(params[:id])
			end

			def update
				@user = User.find(params[:id])
				if @user.update_attributes(user_params)
					respond_with user: @user.as_json
				else
					respond_with error: "Error"
				end
			end

			private
				def user_params
  					params.require(:user).permit(:name, :email, :password, :password_confirmation)
  				end

		end
	end
end