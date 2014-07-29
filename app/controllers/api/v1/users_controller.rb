module Api
	module V1
		class UsersController < ApplicationApiController

			doorkeeper_for :all, except: [:show, :create]
			before_action :correct_resource_owner, only: [:update]
			skip_before_filter :verify_authenticity_token
			respond_to :json


			def index
				@users = User.paginate(page: params[:page], per_page: 15)
				respond_with @users
			end

			def show
				@user = User.find_by(id: params[:id])
				if @user
					@microposts = @user.microposts.paginate(page: params[:page], per_page: 15)
					#@microposts = Micropost.where("user_id = ?", @user.id).limit(5)
					respond_with user: @user, microposts: @microposts
				else 
					respond_to do |format|
						format.json { render json: { error: "User was not found." }, status: :not_found }
					end
				end
			end

			def create
				respond_with User.create(user_params)
			end

			def destroy
				respond_with User.destroy(params[:id])
			end

			def update
				if @user.update_attributes(user_params)
					respond_to do |format|
						format.json { render json: @user, status: :ok }
					end
				else
					respond_to do |format|
						format.json { render json: { error: "There was an error while updating attributes" }, status: :unprocessable_entity }
					end
				end
			end

			private
				def user_params
  					params.require(:user).permit(:name, :email, :password, :password_confirmation)
  				end

  				def correct_resource_owner
  					@user = User.find_by(id: params[:id])
  					unless current_resource_owner?(@user)
  						respond_to do |format|
  							format.json { render json: { error: "Unauthorized access." }, status: :unauthorized }
  						end
  					end
  				end

		end
	end
end