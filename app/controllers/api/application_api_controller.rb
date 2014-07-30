module Api
	class ApplicationApiController < ActionController::Base
		protect_from_forgery with: :null_session
		include Api::SessionsApiHelper
	end
end