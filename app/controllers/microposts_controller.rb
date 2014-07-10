class MicropostsController < ApplicationController
	before_action :signed_in_user, only: [:create, :destroy]
	before_action :correct_user, only: :destroy

	def create
		user = current_user
		@micropost = user.microposts.build(micropost_params)
		if @micropost.save
			flash[:success] = "New micropost is created for #{user.name}!"
			redirect_to root_url
		else
			@feed_items = user.feed.paginate(page: params[:page], per_page: 10)
			render 'static_pages/home'
		end
	end

	def destroy
		@micropost.destroy
		redirect_to root_url
	end

	private
		def micropost_params
			params.require(:micropost).permit(:content)
		end

		def correct_user
			@micropost = current_user.microposts.find_by(id: params[:id])
			redirect_to root_url if @micropost.nil?
		end

end