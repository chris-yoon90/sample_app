module Api
	module SessionsApiHelper
		
		def current_resource_owner?(user)
			if doorkeeper_token
				user == current_resource_owner
			else
				false
			end
		end

		def current_resource_owner
			if doorkeeper_token
				User.find_by(id: doorkeeper_token.resource_owner_id)
			end
		end
	
	end
end