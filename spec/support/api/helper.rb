def create_user_json(user)
	{ 
		name: user.name, 
		email: user.email, 
		password: user.password, 
		password_confirmation: user.password_confirmation
	}
end