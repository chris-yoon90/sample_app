module Api
	module SessionsApiHelper
		
		def current_resource_owner?(user)
			if doorkeeper_token
				user == User.find(doorkeeper_token.resource_owner_id)
			else
				false
			end
		end
	
	end
end