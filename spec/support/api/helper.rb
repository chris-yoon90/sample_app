def create_user_json(user, user_args = {})
	name = user_args[:name] || user.name
	email = user_args[:email] || user.email
	password = user_args[:passowrd] || user.password
	password_confirmation = user_args[:password_confirmation] || user.password_confirmation
	{ 
		name: name, 
		email: email, 
		password: password, 
		password_confirmation: password_confirmation
	}
end

