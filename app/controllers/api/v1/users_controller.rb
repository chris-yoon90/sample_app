class Api::V1::UsersController < ApplicationController

	respond_to :json

	def index
		@users = User.all(limit: 2) #supposed to use paginate
		respond_with @users
	end

	def show
		@user = User.find(params[:id])
		@microposts = @user.microposts.all(limit: 5) #supposed to use paginate
		respond_with user: @user, microposts: @microposts
	end

	def create

	end

	def destroy

	end

	def update

	end

end